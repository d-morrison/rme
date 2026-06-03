# Build the dependency graph of definitions and results in the lecture notes.
#
# This scans every `.qmd` for `def`/`thm`/`lem`/`cor`/`prp` callout divs and the
# cross-references (`@type-id`) inside each one, then saves the resulting graph
# to `inst/extdata/callout-graph.rds`. The `concept-map.qmd` appendix reads that
# saved artifact, so the scan does NOT re-run on every render.
#
# Re-run this script (from the repo root) whenever divs are added, removed, or
# re-titled:
#
#   Rscript data-raw/callout-graph.R

library(igraph)
library(stringr)

`%||%` <- function(a, b) if (is.null(a)) b else a

# Scan all `.qmd` files and return a list of `nodes` and `edges` data frames.
#
# A reference creates a dependency edge from the referenced result to the result
# whose statement or proof contains it. References are attributed to:
#   * the enclosing callout div, if the reference is inside one; otherwise
#   * the callout that an enclosing `proof`/`solution` div *immediately* follows
#     (only blank lines and `---`/slidebreak separators may sit between them).
# References that are neither inside a callout nor inside a directly-attached
# proof (e.g. plain prose) are not turned into edges.
extract_callout_graph <- function(root) {
  qmds <- list.files(
    c(file.path(root, "chapters"), file.path(root, "_subfiles")),
    pattern = "[.]qmd$", recursive = TRUE, full.names = TRUE
  )
  # `chapters/_subfiles` is a symlink to `_subfiles`; drop the duplicate paths.
  qmds <- qmds[!grepl("/chapters/_subfiles/", qmds)]

  open_re <- "^:::+\\s*\\{#(def|thm|lem|cor|prp)-([A-Za-z0-9_-]+)([^}]*)\\}\\s*$"
  head_re <- "^#{2,6}\\s+(.*\\S)\\s*$"
  ref_re  <- "@((?:def|thm|lem|cor|prp)-[A-Za-z0-9_-]+)"
  sep_re  <- "^(-{3,}|\\{\\{< *slidebreak *>\\}\\})$"  # adjacency-preserving lines

  nodes <- list()
  edges <- list()

  for (f in qmds) {
    lines <- readLines(f, warn = FALSE)
    stack <- list()           # open fenced divs, innermost last; may carry $owner
    pending <- NA_character_   # callout just closed, still adjacent to a proof
    n <- length(lines)
    for (i in seq_len(n)) {
      l <- lines[i]

      mo <- str_match(l, open_re)
      if (!is.na(mo[1, 1])) {
        type <- mo[1, 2]
        full <- paste0(type, "-", mo[1, 3])
        # The title is the heading on the first non-blank line inside the div.
        title <- NA_character_
        for (j in seq(i + 1, min(i + 5, n))) {
          if (j > n || str_trim(lines[j]) != "") {
            hm <- str_match(lines[j], head_re)
            if (!is.na(hm[1, 1])) title <- hm[1, 2]
            break
          }
        }
        nodes[[full]] <- data.frame(
          id = full, type = type,
          title = title %||% full,
          file = sub(paste0(root, "/"), "", f, fixed = TRUE),
          stringsAsFactors = FALSE
        )
        stack[[length(stack) + 1]] <- list(kind = "callout", id = full)
        pending <- NA_character_
        next
      }

      if (grepl("^:::+", l)) {
        content <- str_trim(sub("^:::+", "", l))
        if (nzchar(content)) {
          # A proof/solution div directly following a callout inherits it.
          is_proof <- grepl("proof|solution", content, ignore.case = TRUE)
          owner <- if (is_proof) pending else NA_character_
          stack[[length(stack) + 1]] <-
            list(kind = "div", class = content, owner = owner)
          pending <- NA_character_
        } else if (length(stack)) {
          top <- stack[[length(stack)]]
          stack[[length(stack)]] <- NULL
          pending <- if (top$kind == "callout") top$id else NA_character_
        }
        next
      }

      refs <- str_match_all(l, ref_re)[[1]]
      if (nrow(refs)) {
        target <- NA_character_
        for (k in rev(seq_along(stack))) {
          s <- stack[[k]]
          if (s$kind == "callout") {
            target <- s$id
            break
          }
          if (!is.null(s$owner) && !is.na(s$owner)) {
            target <- s$owner
            break
          }
        }
        if (!is.na(target)) {
          for (r in refs[, 2]) {
            if (r != target) {
              edges[[length(edges) + 1]] <-
                data.frame(from = r, to = target, stringsAsFactors = FALSE)
            }
          }
        }
      }

      # Real content at the top level ends the previous callout's eligibility to
      # bind a following proof (blank lines and separators don't count).
      trimmed <- str_trim(l)
      if (!length(stack) && trimmed != "" && !grepl(sep_re, trimmed)) {
        pending <- NA_character_
      }
    }
  }

  nodes <- do.call(rbind, nodes)
  rownames(nodes) <- NULL
  edges <- if (length(edges)) unique(do.call(rbind, edges)) else
    data.frame(from = character(), to = character())
  edges <- edges[edges$from %in% nodes$id & edges$to %in% nodes$id, , drop = FALSE]
  rownames(edges) <- NULL
  list(nodes = nodes, edges = edges)
}

root <- here::here()
cg <- extract_callout_graph(root)

# Precompute descendant counts and the direct/indirect descendant id lists, so
# the chapter does no graph analysis at render time.
ig <- graph_from_data_frame(cg$edges, vertices = cg$nodes, directed = TRUE)
cg$nodes$n_desc <- vapply(
  cg$nodes$id,
  function(v) length(subcomponent(ig, v, mode = "out")) - 1L,
  integer(1)
)
cg$nodes$n_direct <- as.integer(degree(ig, mode = "out")[cg$nodes$id])

cg$descendants <- lapply(stats::setNames(cg$nodes$id, cg$nodes$id), function(v) {
  direct <- setdiff(names(which(distances(ig, v, mode = "out")[1, ] == 1)), v)
  reach  <- setdiff(subcomponent(ig, v, mode = "out")$name, v)
  list(direct = sort(direct), indirect = sort(setdiff(reach, direct)))
})

cg$generated_from <- "data-raw/callout-graph.R"

saveRDS(cg, here::here("inst/extdata/callout-graph.rds"))

message(sprintf(
  "callout-graph.rds: %d results, %d dependency links (%d results with >=1 descendant)",
  nrow(cg$nodes), nrow(cg$edges), sum(cg$nodes$n_direct >= 1)
))
