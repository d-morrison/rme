function slidebreak(args, kwargs, meta)
  if quarto.doc.isFormat("revealjs") then
    return pandoc.HorizontalRule()
  end
  return {}
end
