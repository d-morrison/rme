function Pandoc(doc)
  local blocks = {}

  for i, block in ipairs(doc.blocks) do
    table.insert(blocks, block)

    if block.t == "Header" and block.level == 1 then
      local next_block = doc.blocks[i + 1]
      if not (next_block and next_block.t == "HorizontalRule") then
        table.insert(blocks, pandoc.HorizontalRule())
      end
    end
  end

  return pandoc.Pandoc(blocks, doc.meta)
end
