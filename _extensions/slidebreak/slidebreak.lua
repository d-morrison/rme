function slidebreak(args, kwargs, meta)
  if quarto.doc.is_format("revealjs") then
    return pandoc.HorizontalRule()
  end
  return {}
end
