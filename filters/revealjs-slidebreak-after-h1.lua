function Pandoc(doc)
  local blocks = {}

  for i, block in ipairs(doc.blocks) do
    table.insert(blocks, block)

    if block.t == "Header" and block.level == 1 then
      local next_block = doc.blocks[i + 1]
      local has_level2_next = next_block
        and next_block.t == "Header"
        and next_block.level == 2
      if not has_level2_next then
        table.insert(
          blocks,
          pandoc.Header(
            2,
            { pandoc.Str("\u{200B}") },
            pandoc.Attr("", { "unnumbered", "slide-break-after-h1" })
          )
        )
      end
    end
  end

  return pandoc.Pandoc(blocks, doc.meta)
end
