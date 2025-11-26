-- simpleslides Quarto Extension
-- Authors: John Paul Helveston, Pingfan Hu
-- Version: 0.1.0

-- Helper function to check if format is revealjs
local function is_revealjs()
  return quarto.doc.is_format("revealjs")
end

-- Helper function to extract classes from pattern like .class1.class2[
local function extract_classes(text)
  local classes = {}
  local remaining = text

  -- Match pattern: .classname repeated
  while true do
    local class_name = remaining:match("^%.([%w_-]+)")
    if class_name then
      table.insert(classes, class_name)
      remaining = remaining:sub(#class_name + 2) -- Skip . and class name
    else
      break
    end
  end

  return classes, remaining
end

-- Helper function to find matching closing bracket
-- Returns the position of the matching closing bracket
local function find_matching_bracket(text, start_pos)
  local depth = 0
  local i = start_pos

  while i <= #text do
    local char = text:sub(i, i)

    if char == '[' then
      depth = depth + 1
    elseif char == ']' then
      if depth == 0 then
        return i
      end
      depth = depth - 1
    elseif char == '\\' then
      -- Skip escaped characters
      i = i + 1
    end

    i = i + 1
  end

  return nil
end

-- Helper function to check if content has block-level elements
local function has_block_elements(blocks)
  if #blocks == 0 then
    return false
  end

  -- More than one block means block-level
  if #blocks > 1 then
    return true
  end

  -- Check if the single block is Plain or Para (both can be inline if single)
  local first_block = blocks[1]
  if first_block.t == "Plain" or first_block.t == "Para" then
    -- Single Plain or Para is treated as inline
    -- Only treat as block if there are multiple blocks or other block types
    return false
  end

  -- Any other block type (List, CodeBlock, etc.) is block-level
  return true
end

-- Helper function to extract hex colors and generate inline styles
-- Returns: filtered_classes (non-color classes), style_string
local function process_hex_colors(classes)
  local filtered_classes = {}
  local styles = {}

  for _, class in ipairs(classes) do
    -- Match .color-HEXCODE (6 hex digits)
    local hex = class:match("^color%-([%x][%x][%x][%x][%x][%x])$")
    if hex then
      table.insert(styles, "color: #" .. hex)
    else
      -- Match .bg-color-HEXCODE
      local bg_hex = class:match("^bg%-color%-([%x][%x][%x][%x][%x][%x])$")
      if bg_hex then
        table.insert(styles, "background-color: #" .. bg_hex)
      else
        -- Not a hex color, keep as regular class
        table.insert(filtered_classes, class)
      end
    end
  end

  local style_string = ""
  if #styles > 0 then
    style_string = table.concat(styles, "; ")
  end

  return filtered_classes, style_string
end

-- Process inline elements to find .class[content] patterns
function Inlines(inlines)
  if not is_revealjs() then
    return nil
  end

  local result = pandoc.List()
  local i = 1

  while i <= #inlines do
    local elem = inlines[i]

    -- Check if this is a Str element starting with .
    if elem.t == "Str" and elem.text:match("^%.%w") then
      -- Try to extract class pattern
      local classes, remaining = extract_classes(elem.text)

      if #classes > 0 and remaining:match("^%[") then
        -- Found a class pattern! Now extract the content
        -- We need to collect all inlines until we find the matching ]

        -- Start collecting content after the [
        local content_inlines = pandoc.List()
        local bracket_depth = 1
        local found_closing = false

        -- Handle remaining text in current element after [
        local after_bracket = remaining:sub(2) -- Skip the [
        if after_bracket and #after_bracket > 0 then
          -- Check if closing bracket is in this same element
          local close_pos = find_matching_bracket(after_bracket, 1)
          if close_pos then
            -- Closing bracket found in same element
            local content_text = after_bracket:sub(1, close_pos - 1)
            if #content_text > 0 then
              content_inlines:insert(pandoc.Str(content_text))
            end
            found_closing = true

            -- Check if there's text after the ]
            local after_close = after_bracket:sub(close_pos + 1)
            if #after_close > 0 then
              -- Re-insert remaining text for next iteration
              table.insert(inlines, i + 1, pandoc.Str(after_close))
            end
          else
            -- No closing bracket yet, add this text
            content_inlines:insert(pandoc.Str(after_bracket))
          end
        end

        -- If not found, continue scanning forward
        if not found_closing then
          local j = i + 1
          while j <= #inlines and not found_closing do
            local next_elem = inlines[j]

            if next_elem.t == "Str" then
              local close_pos = find_matching_bracket(next_elem.text, 1)
              if close_pos then
                -- Found closing bracket
                local before_close = next_elem.text:sub(1, close_pos - 1)
                if #before_close > 0 then
                  content_inlines:insert(pandoc.Str(before_close))
                end
                found_closing = true

                -- Handle text after ]
                local after_close = next_elem.text:sub(close_pos + 1)
                if #after_close > 0 then
                  table.insert(inlines, j + 1, pandoc.Str(after_close))
                end

                break
              else
                -- No closing bracket, include whole element
                content_inlines:insert(next_elem)
              end
            else
              -- Include non-Str elements as-is
              content_inlines:insert(next_elem)
            end

            j = j + 1
          end

          if found_closing then
            i = j -- Skip past the processed elements
          end
        end

        if found_closing then
          -- Parse the content to determine if it's block or inline
          -- Convert inlines to markdown text
          local content_md = pandoc.write(pandoc.Pandoc(pandoc.Plain(content_inlines)), 'markdown')

          -- Parse it back to check for block elements
          local parsed = pandoc.read(content_md, 'markdown')

          -- Process hex colors and generate inline styles
          local filtered_classes, style_string = process_hex_colors(classes)

          -- Create attributes with both classes and inline styles
          local attr
          if style_string ~= "" then
            attr = pandoc.Attr("", filtered_classes, {{"style", style_string}})
          else
            attr = pandoc.Attr("", filtered_classes)
          end

          if has_block_elements(parsed.blocks) then
            -- Create a Div (block-level)
            -- Note: We can't return a Div from Inlines filter
            -- So we'll wrap it in a RawInline with HTML
            local div = pandoc.Div(parsed.blocks, attr)
            local html = pandoc.write(pandoc.Pandoc({div}), 'html')
            result:insert(pandoc.RawInline('html', html))
          else
            -- Create a Span (inline)
            local span_content = parsed.blocks[1] and parsed.blocks[1].content or content_inlines
            result:insert(pandoc.Span(span_content, attr))
          end

          i = i + 1
          goto continue
        end
      end
    end

    -- No pattern found, keep element as-is
    result:insert(elem)
    i = i + 1

    ::continue::
  end

  return result
end

-- Transform horizontal rules into slide separators for revealjs
-- Note: In Quarto, --- already works as slide breaks by default
-- when not at the beginning of the document. We don't need to transform it.
-- function HorizontalRule(elem)
--   if not is_revealjs() then
--     return nil
--   end
--   -- Keep default behavior
--   return nil
-- end

-- Alternative approach: Process at Block level for better Div handling
function Para(elem)
  if not is_revealjs() then
    return nil
  end

  -- Check if this paragraph starts with a class pattern
  if #elem.content > 0 then
    local first = elem.content[1]
    if first.t == "Str" and first.text:match("^%.%w") then
      -- This might be a block-level class pattern
      -- Process the inlines
      local new_inlines = Inlines(elem.content)
      if new_inlines then
        -- Check if we created a RawInline with HTML
        -- If so, convert to RawBlock
        if #new_inlines == 1 and new_inlines[1].t == "RawInline" and new_inlines[1].format == "html" then
          return pandoc.RawBlock('html', new_inlines[1].text)
        end
        return pandoc.Para(new_inlines)
      end
    end
  end

  return nil
end

-- Return the filters
return {
  {Para = Para},
  {Inlines = Inlines}
}
