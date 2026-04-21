local function sanitize(tex)
  local out = tex
  out = out:gsub("\\text%s+E", "\\mathrm{E}")
  out = out:gsub("\\left%((.-)\\atop%s*(.-)\\right%)", "\\binom{%1}{%2}")
  out = out:gsub(
    "\\left\\{%s*(%b{})%s*\\atop%s*(%b{})%s*\\right%.",
    "\\begin{cases} %1 \\\\ %2 \\end{cases}"
  )
  out = out:gsub("\\atop%s*(%b{})", "%1")
  out = out:gsub("\\color%s*%b{}", "")
  out = out:gsub("\\\\", " ")
  out = out:gsub("[\\\\]+,", "\\,")
  return out
end

function Math(el)
  if not FORMAT:match("docx") then
    return nil
  end

  local sanitized = sanitize(el.text)
  if sanitized == el.text then
    return nil
  end

  el.text = sanitized
  return el
end
