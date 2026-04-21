function Pandoc(doc)
  local blocks = {}

  for i, block in ipairs(doc.blocks) do
    table.insert(blocks, block)

    if block.t == "Header" and block.level == 1 then
      local next_block = doc.blocks[i + 1]
      local starts_new_slide_next = not next_block
        or next_block.t == "HorizontalRule"
        or (
          next_block.t == "Header"
          and (next_block.level == 1 or next_block.level == 2)
        )
      if not starts_new_slide_next then
        table.insert(blocks, pandoc.HorizontalRule())
      end
    end
  end

  return pandoc.Pandoc(blocks, doc.meta)
end
