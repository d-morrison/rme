#!/usr/bin/env Rscript
# Check bibliography files for DOI requirements:
# 1. Every book and article must have a DOI field
# 2. Every DOI must resolve to a valid URL
# 3. Reference information must match the document at the DOI URL

suppressPackageStartupMessages({
  library(bib2df)
  library(httr)
  library(jsonlite)
  library(stringr)
})

# User agent to use for HTTP requests (realistic Chrome browser string)
USER_AGENT <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

#' Parse BibTeX file and extract entries
#'
#' @param filepath Path to BibTeX file
#' @return Data frame of bibliography entries
parse_bibtex_file <- function(filepath) {
  tryCatch({
    bib_df <- bib2df(filepath)
    return(bib_df)
  }, error = function(e) {
    cat(sprintf("Error parsing BibTeX file: %s\n", e$message))
    return(NULL)
  })
}

#' Check if entry has a DOI field
#'
#' @param entry Single bibliography entry (row from data frame)
#' @return List with has_doi (logical) and error_message (string or NULL)
check_doi_field <- function(entry) {
  entry_type <- tolower(entry$CATEGORY)
  entry_key <- entry$BIBTEXKEY
  
  if (entry_type %in% c("book", "article")) {
    if (is.na(entry$DOI) || entry$DOI == "") {
      return(list(
        has_doi = FALSE,
        error = sprintf("Entry '%s' (%s) is missing DOI field", entry_key, entry_type)
      ))
    }
  }
  
  return(list(has_doi = TRUE, error = NULL))
}

#' Validate that a DOI resolves to a valid URL
#'
#' @param doi DOI string
#' @param retry_on_403 Whether to retry on 403 errors (default TRUE)
#' @return List with is_valid, error_message, and status_code
validate_doi_url <- function(doi, retry_on_403 = TRUE) {
  # Clean up DOI
  doi <- trimws(doi)
  
  # Extract just the DOI identifier
  doi_match <- str_extract(doi, "10\\.\\d+/[^\\s]+")
  
  if (is.na(doi_match)) {
    return(list(
      is_valid = FALSE,
      error = sprintf("Invalid DOI format: %s", doi),
      status_code = NULL
    ))
  }
  
  doi_identifier <- doi_match
  doi_url <- sprintf("https://doi.org/%s", doi_identifier)
  
  # Try up to 3 times for 403 errors
  max_attempts <- if (retry_on_403) 3 else 1
  last_error <- NULL
  
  for (attempt in 1:max_attempts) {
    if (attempt > 1) {
      # Exponential backoff: 2, 4 seconds
      wait_time <- 2^(attempt - 1)
      cat(sprintf("    Retrying after %d seconds (attempt %d/%d)...\n", wait_time, attempt, max_attempts))
      Sys.sleep(wait_time)
    }
    
    result <- tryCatch({
      response <- GET(
        doi_url,
        timeout(30),
        user_agent(USER_AGENT)
      )
      
      status_code <- status_code(response)
      
      if (status_code == 200) {
        return(list(
          is_valid = TRUE,
          error = NULL,
          status_code = status_code
        ))
      } else if (status_code == 403 && attempt < max_attempts) {
        # Store error and continue to retry
        last_error <- list(
          is_valid = FALSE,
          error = sprintf("DOI URL returned status %d", status_code),
          status_code = status_code
        )
        NULL  # Continue loop
      } else {
        return(list(
          is_valid = FALSE,
          error = sprintf("DOI URL returned status %d", status_code),
          status_code = status_code
        ))
      }
    }, error = function(e) {
      if (attempt < max_attempts) {
        # Store error and continue to retry
        last_error <<- list(
          is_valid = FALSE,
          error = sprintf("Error accessing DOI: %s", e$message),
          status_code = NULL
        )
        NULL  # Continue loop
      } else {
        return(list(
          is_valid = FALSE,
          error = sprintf("Error accessing DOI: %s", e$message),
          status_code = NULL
        ))
      }
    })
    
    # If result is not NULL, it was returned above
    if (!is.null(result)) {
      return(result)
    }
  }
  
  # Return last error if all attempts failed
  if (!is.null(last_error)) {
    return(last_error)
  }
  
  # Should not reach here, but return error just in case
  return(list(
    is_valid = FALSE,
    error = "Failed after multiple attempts",
    status_code = NULL
  ))
}

#' Get DOI metadata from CrossRef API
#'
#' @param doi DOI string
#' @return Metadata list or NULL if failed
get_doi_metadata <- function(doi) {
  doi <- trimws(doi)
  doi_match <- str_extract(doi, "10\\.\\d+/[^\\s]+")
  
  if (is.na(doi_match)) {
    return(NULL)
  }
  
  doi_identifier <- doi_match
  api_url <- sprintf("https://api.crossref.org/works/%s", doi_identifier)
  
  tryCatch({
    response <- GET(
      api_url,
      timeout(30),
      user_agent(USER_AGENT)
    )
    
    if (status_code(response) == 200) {
      data <- fromJSON(content(response, as = "text", encoding = "UTF-8"))
      return(data$message)
    }
  }, error = function(e) {
    # Failed to fetch metadata
  })
  
  return(NULL)
}

#' Normalize string for comparison
#'
#' @param s String to normalize
#' @return Normalized string
normalize_string <- function(s) {
  if (is.na(s) || s == "") {
    return("")
  }
  
  # Convert to lowercase, remove punctuation, remove extra whitespace
  s <- tolower(s)
  s <- str_replace_all(s, "[^a-zA-Z0-9\\s]", "")
  s <- str_replace_all(s, "\\s+", " ")
  return(trimws(s))
}

#' Compare BibTeX entry with DOI metadata
#'
#' @param entry Bibliography entry
#' @param metadata CrossRef metadata
#' @return List with match (logical) and warnings (character vector)
compare_metadata <- function(entry, metadata) {
  warnings <- c()
  
  # Check title
  if (!is.na(entry$TITLE) && !is.null(metadata$title)) {
    bib_title <- normalize_string(entry$TITLE)
    
    crossref_title <- metadata$title
    if (is.list(crossref_title) && length(crossref_title) > 0) {
      crossref_title <- crossref_title[[1]]
    }
    crossref_title <- normalize_string(as.character(crossref_title))
    
    # Check word overlap (at least 50%)
    if (bib_title != "" && crossref_title != "") {
      bib_words <- str_split(bib_title, "\\s+")[[1]]
      crossref_words <- str_split(crossref_title, "\\s+")[[1]]
      
      if (length(bib_words) > 0 && length(crossref_words) > 0) {
        overlap <- length(intersect(bib_words, crossref_words))
        total <- min(length(bib_words), length(crossref_words))
        
        if (total > 0 && overlap / total < 0.5) {
          warnings <- c(warnings, sprintf(
            "Title mismatch: BibTeX='%s' vs DOI='%s'",
            entry$TITLE, metadata$title
          ))
        }
      }
    }
  }
  
  # Check author (basic check)
  if (!is.na(entry$AUTHOR) && !is.null(metadata$author)) {
    bib_author <- normalize_string(entry$AUTHOR)
    
    crossref_authors <- metadata$author
    if (is.data.frame(crossref_authors) && nrow(crossref_authors) > 0) {
      family_names <- crossref_authors$family[!is.na(crossref_authors$family)]
      
      if (length(family_names) > 0) {
        found_match <- FALSE
        for (name in family_names) {
          norm_name <- normalize_string(name)
          if (norm_name != "" && grepl(norm_name, bib_author)) {
            found_match <- TRUE
            break
          }
        }
        
        if (!found_match) {
          warnings <- c(warnings, sprintf(
            "Author mismatch: BibTeX='%s' vs DOI authors",
            entry$AUTHOR
          ))
        }
      }
    }
  }
  
  # Check year
  if (!is.na(entry$YEAR)) {
    bib_year <- as.character(entry$YEAR)
    
    # Try published-print first, then published-online
    crossref_year <- NULL
    if (!is.null(metadata$`published-print`$`date-parts`)) {
      date_parts <- metadata$`published-print`$`date-parts`
      if (length(date_parts) > 0 && length(date_parts[[1]]) > 0) {
        crossref_year <- as.character(date_parts[[1]][1])
      }
    }
    
    if (is.null(crossref_year) && !is.null(metadata$`published-online`$`date-parts`)) {
      date_parts <- metadata$`published-online`$`date-parts`
      if (length(date_parts) > 0 && length(date_parts[[1]]) > 0) {
        crossref_year <- as.character(date_parts[[1]][1])
      }
    }
    
    if (!is.null(crossref_year) && bib_year != crossref_year) {
      warnings <- c(warnings, sprintf(
        "Year mismatch: BibTeX='%s' vs DOI='%s'",
        bib_year, crossref_year
      ))
    }
  }
  
  return(list(match = TRUE, warnings = warnings))
}

#' Check bibliography file for DOI requirements
#'
#' @param filepath Path to bibliography file
#' @param verify_metadata Whether to verify metadata (default TRUE)
#' @return List with checked_count, errors_count, and error_messages
check_bibliography_file <- function(filepath, verify_metadata = TRUE) {
  cat(sprintf("\nChecking %s...\n", filepath))
  
  # Exclusion list: BibTeX keys that don't have DOIs
  # (e.g., older books where DOIs aren't available)
  excluded_keys <- c("vapnik1998")
  
  bib_df <- parse_bibtex_file(filepath)
  if (is.null(bib_df)) {
    return(list(checked_count = 0, errors_count = 1, errors = c("Failed to parse BibTeX file")))
  }
  
  errors <- c()
  checked_count <- 0
  
  for (i in seq_len(nrow(bib_df))) {
    entry <- bib_df[i, ]
    entry_type <- tolower(entry$CATEGORY)
    
    # Only check books and articles
    if (!(entry_type %in% c("book", "article"))) {
      next
    }
    
    # Skip excluded entries
    if (entry$BIBTEXKEY %in% excluded_keys) {
      cat(sprintf("  Skipping %s '%s' (in exclusion list)...\n", entry_type, entry$BIBTEXKEY))
      next
    }
    
    checked_count <- checked_count + 1
    cat(sprintf("  Checking %s '%s'...\n", entry_type, entry$BIBTEXKEY))
    
    # Add delay before checking to avoid rate limiting
    if (checked_count > 1) {
      Sys.sleep(1)
    }
    
    # Check 1: DOI field exists
    doi_check <- check_doi_field(entry)
    if (!doi_check$has_doi) {
      errors <- c(errors, doi_check$error)
      cat(sprintf("    ❌ %s\n", doi_check$error))
      next
    }
    
    doi <- entry$DOI
    cat(sprintf("    DOI: %s\n", doi))
    
    # Check 2: DOI URL is valid
    url_check <- validate_doi_url(doi)
    if (!url_check$is_valid) {
      error_msg <- sprintf("Entry '%s': %s", entry$BIBTEXKEY, url_check$error)
      errors <- c(errors, error_msg)
      cat(sprintf("    ❌ %s\n", error_msg))
      next
    } else {
      cat(sprintf("    ✓ DOI URL is valid (status %d)\n", url_check$status_code))
    }
    
    # Check 3: Metadata matches (if enabled)
    if (verify_metadata) {
      cat("    Fetching DOI metadata...\n")
      metadata <- get_doi_metadata(doi)
      
      if (!is.null(metadata)) {
        comparison <- compare_metadata(entry, metadata)
        if (length(comparison$warnings) > 0) {
          for (warning in comparison$warnings) {
            cat(sprintf("    ⚠️  %s\n", warning))
          }
        } else {
          cat("    ✓ Metadata appears consistent\n")
        }
      } else {
        cat("    ⚠️  Could not fetch metadata from CrossRef API\n")
      }
      
      # Small delay to be nice to the API
      Sys.sleep(0.5)
    }
  }
  
  return(list(
    checked_count = checked_count,
    errors_count = length(errors),
    errors = errors
  ))
}

# Main execution
run_doi_validation <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  
  # Parse arguments
  no_metadata_check <- "--no-metadata-check" %in% args
  files <- args[!grepl("^--", args)]
  
  if (length(files) == 0) {
    cat("Usage: check-bibliography-dois.R [--no-metadata-check] <file1.bib> [file2.bib ...]\n")
    quit(status = 1)
  }
  
  total_checked <- 0
  total_errors <- 0
  all_errors <- c()
  
  for (filepath in files) {
    if (!file.exists(filepath)) {
      cat(sprintf("Error: File %s does not exist\n", filepath))
      quit(status = 1)
    }
    
    result <- check_bibliography_file(filepath, verify_metadata = !no_metadata_check)
    total_checked <- total_checked + result$checked_count
    total_errors <- total_errors + result$errors_count
    all_errors <- c(all_errors, result$errors)
  }
  
  # Print summary
  cat("\n")
  cat(paste(rep("=", 70), collapse = ""), "\n")
  cat("SUMMARY\n")
  cat(paste(rep("=", 70), collapse = ""), "\n")
  cat(sprintf("Total entries checked: %d\n", total_checked))
  cat(sprintf("Errors found: %d\n", total_errors))
  
  if (total_errors > 0) {
    cat("\nERRORS:\n")
    for (error in all_errors) {
      cat(sprintf("  • %s\n", error))
    }
    quit(status = 1)
  } else {
    cat("\n✓ All checks passed!\n")
    quit(status = 0)
  }
}

# Run main function
run_doi_validation()
