# simpleslides Quarto Extension - Implementation Plan

**Authors:** John Paul Helveston, Pingfan Hu
**Date:** 2025-11-25
**Extension Type:** Shortcode/Filter (Lua-based)

## Overview

simpleslides is a Quarto extension that simplifies the creation and editing of Quarto slides by providing intuitive syntax for common formatting tasks, inspired by the xaringan R package.

### Core Philosophy
- Make slide creation more intuitive and less verbose
- Reduce reliance on raw HTML for basic formatting
- **Eliminate verbose `:::` fences** - use `.class[content]` for both inline and block-level elements
- **Free up `##` headers** for actual headings by using `---` for slide breaks (xaringan-style)
- Provide xaringan-like syntax convenience for Quarto users
- Maintain compatibility with standard Quarto/Reveal.js features

## Target Features

### TIER 1: Core Syntax Transformations (Priority: CRITICAL)

#### 1.1. Slide Separators with `---`
**Problem:** `##` is used for slide breaks, taking away its role as a section header.

**Current Quarto:**
```markdown
## Slide 1
Content here

## Slide 2
Cannot use ## for actual headings!
```

**Proposed Syntax:**
```markdown
---
# Slide 1 Title (optional)
## This is now a real header!
Content here

---
## Another real header
More content
```

**Implementation:**
- Intercept `HorizontalRule` elements (`---` in markdown)
- Transform to Reveal.js slide breaks
- Preserve `##` for actual heading purposes
- **Complexity:** Low - straightforward AST transformation

#### 1.2. Class Syntax for Inline & Block Content
**Problem:** Requires verbose HTML for colors and verbose `:::` fences for divs.

**Current Quarto:**
```html
<span style="color: #2C8475;">Colored text</span>

::: {.columns}
::: {.column}
Left
:::
::: {.column}
Right
:::
:::
```

**Proposed Syntax:**
```markdown
.teal[Colored text]

.pull-left[
Left column with **markdown**
- Lists work
]

.pull-right[
Right column
]
```

**Implementation:**
- Parse `.classname[content]` pattern
- **Detect content type:** If contains block elements → `pandoc.Div`, else → `pandoc.Span`
- Support nested brackets and multiple classes: `.red.bold[text]`
- **Complexity:** Medium-High - requires block/inline detection

### TIER 2: Predefined Utility Classes (Priority: HIGH)

#### 2.1. Color Classes
- **Text colors:** `.red`, `.blue`, `.green`, `.yellow`, `.orange`, `.purple`, `.gray`, `.pink`, `.teal`
- **Background colors:** `.bg-red`, `.bg-blue`, `.bg-green`, etc.
- **Semantic colors:** `.primary`, `.secondary`, `.accent`, `.muted`

#### 2.2. Typography Utilities
- **Size:** `.large`, `.larger`, `.huge`, `.small`, `.smaller`, `.tiny`
- **Weight:** `.bold`, `.light`
- **Style:** `.italic`, `.underline`, `.strike`

#### 2.3. Layout Utilities (xaringan-inspired)
- `.pull-left[...]`, `.pull-right[...]` - Two-column layouts (xaringan classic)
- `.columns[...]` - Flex container for multiple columns
- `.col[...]` - Individual column (auto-width)
- `.center[...]` - Centered content

### TIER 3: Reveal.js Integration Shortcuts (Priority: MEDIUM)

#### 3.1. Fragments (Incremental Reveals)
**Current Quarto:**
```markdown
::: {.fragment}
Appears incrementally
:::
```

**Proposed:**
```markdown
.fragment[Appears incrementally]
```

#### 3.2. Speaker Notes
**Current Quarto:**
```markdown
::: {.notes}
Speaker notes here
:::
```

**Proposed:**
```markdown
.notes[
Speaker notes here
Can span multiple lines
]
```

#### 3.3. Column Layouts
**Current Quarto:** Requires nested `:::` fences

**Proposed:**
```markdown
.columns[
.col[First column]
.col[Second column]
.col[Third column]
]
```

### TIER 4: Advanced Helpers (Priority: LOW - Future)

- `.img-center[...]`, `.img-50[...]` - Image positioning and sizing
- Slide backgrounds: `--- {.bg-teal}` or `.bg-image[path.jpg]`
- Custom pause points
- Font size shortcuts: `.size-150[150% text]`

## Technical Implementation

### Extension Structure

```
simpleslides/
├── _extensions/
│   └── simpleslides/
│       ├── _extension.yml          # Extension metadata and config
│       ├── simpleslides.lua        # Main Lua filter
│       ├── simpleslides.scss       # Color and utility classes
│       └── assets/
│           └── logo.png            # (Optional) Extension branding
├── _example/
│   ├── example.qmd                 # Complete example slides
│   └── assets/                     # Example images, etc.
├── PLAN.md                         # This file
├── README.md                       # User documentation
└── LICENSE                         # License file

```

### Component Details

#### 1. `_extension.yml`
```yaml
title: simpleslides
author:
  - John Paul Helveston
  - Pingfan Hu
version: 0.1.0
quarto-required: ">=1.4.0"
contributes:
  filters:
    - simpleslides.lua
  format:
    revealjs:
      theme: simpleslides.scss
```

#### 2. `simpleslides.lua` - Lua Filter

**Core Functionality:**
1. **Slide separator transformation:** `---` → Reveal.js slide breaks
2. **Class syntax transformation:** `.classname[content]` → Span or Div
3. **Block vs. Inline detection:** Automatically choose correct element type
4. **Nested brackets support:** Handle `[text with [brackets]]`
5. **Multiple classes:** Support `.red.bold[text]`

**Algorithm for Slide Separators:**
```lua
function HorizontalRule(elem)
  -- Transform --- into slide separator
  -- In Reveal.js, this is handled by slide-level setting
  -- Return appropriate slide break marker
  return pandoc.RawBlock('html', '</section><section>')
end
```

**Algorithm for Class Syntax:**
```lua
-- Strategy: Process at string level to handle raw markdown
function Str(elem)
  local text = elem.text

  -- Check for pattern: .classname[
  if text:match("^%.([%w_-]+)%[") then
    -- This is the start of a class pattern
    -- Mark for processing in Inlines filter
  end

  return elem
end

function Inlines(inlines)
  -- Process sequence of inlines to extract .class[content] patterns
  local result = {}
  local i = 1

  while i <= #inlines do
    if isClassPattern(inlines, i) then
      -- Extract classes and content
      local classes = extractClasses(inlines, i)
      local content, endPos = extractBracketedContent(inlines, i)

      -- Parse content as markdown to detect blocks
      local parsedContent = parseMarkdown(content)

      -- Decide: Span or Div?
      if hasBlockElements(parsedContent) then
        table.insert(result, pandoc.Div(parsedContent, {class = classes}))
      else
        table.insert(result, pandoc.Span(parsedContent, {class = classes}))
      end

      i = endPos + 1
    else
      table.insert(result, inlines[i])
      i = i + 1
    end
  end

  return result
end

-- Key helper: Detect if content has block-level elements
function hasBlockElements(blocks)
  if #blocks == 0 then return false end

  -- More than one block → definitely block-level
  if #blocks > 1 then return true end

  -- Single Para is inline, anything else is block
  if blocks[1].t == "Plain" then
    return false
  end

  return true
end
```

**Bracket Matching Algorithm:**
```lua
function extractBracketedContent(inlines, startPos)
  local depth = 0
  local content = {}
  local i = startPos

  -- Find opening [
  while i <= #inlines and not isOpenBracket(inlines[i]) do
    i = i + 1
  end

  i = i + 1  -- Skip opening [
  local contentStart = i

  -- Match brackets
  while i <= #inlines do
    if isOpenBracket(inlines[i]) then
      depth = depth + 1
    elseif isCloseBracket(inlines[i]) then
      if depth == 0 then
        -- Found matching bracket
        return extractRange(inlines, contentStart, i-1), i
      end
      depth = depth - 1
    end
    i = i + 1
  end

  error("Unmatched bracket in class syntax")
end
```

#### 3. `simpleslides.scss` - Styles

**Color Palette:**
```scss
// Define accessible color palette
$red: #E74C3C;
$blue: #3498DB;
$green: #2ECC71;
$yellow: #F39C12;
$orange: #E67E22;
$purple: #9B59B6;
$gray: #95A5A6;
$pink: #FD79A8;
$teal: #2C8475;

// Text color classes
.red { color: $red; }
.blue { color: $blue; }
// ... etc

// Background color classes
.bg-red {
  background-color: $red;
  color: white;
  padding: 0.2em 0.4em;
  border-radius: 0.2em;
}
// ... etc

// Typography utilities
.large { font-size: 1.3em; }
.larger { font-size: 1.5em; }
.huge { font-size: 2em; }
.small { font-size: 0.85em; }
.smaller { font-size: 0.7em; }
.tiny { font-size: 0.6em; }

.bold { font-weight: bold; }
.italic { font-style: italic; }

// Layout utilities - xaringan inspired
.center {
  text-align: center;
  display: block;
}

// Two-column layout (xaringan classic)
.pull-left {
  float: left;
  width: 47%;
}

.pull-right {
  float: right;
  width: 47%;
}

// Modern flexbox columns
.columns {
  display: flex;
  gap: 1em;
  align-items: flex-start;

  .col {
    flex: 1;
  }
}

// Reveal.js integration
.notes {
  // Speaker notes styling if needed
}

.fragment {
  // Fragment reveal styling (handled by Reveal.js)
}
```

## Development Phases

### Phase 1: Core Setup (Milestone 1)
- [x] Create PLAN.md
- [x] Add `.claude/` to .gitignore
- [ ] Create basic extension structure (`_extension.yml`)
- [ ] Create minimal Lua filter skeleton
- [ ] Create basic SCSS file
- [ ] Test extension loads without errors

**Success Criteria:** Extension can be installed and doesn't break Quarto rendering

### Phase 2: Slide Separator with `---` (Milestone 2)
- [ ] Implement `HorizontalRule` → slide break transformation
- [ ] Test basic slide separation
- [ ] Verify `##` headers work as actual headers
- [ ] Handle edge cases (code blocks, etc.)

**Success Criteria:** `---` creates new slides, `##` creates headers within slides

### Phase 3: Basic Inline Class Syntax (Milestone 3)
- [ ] Implement string-level pattern matching for `.class[text]`
- [ ] Handle simple inline cases (single class, no nesting)
- [ ] Create SCSS with basic color classes (red, blue, green)
- [ ] Test `.red[text]` renders as red text

**Success Criteria:** `.red[text]` and similar simple patterns work

### Phase 4: Block-Level Class Syntax (Milestone 4)
- [ ] Implement block vs. inline detection
- [ ] Parse multi-line content inside `[...]`
- [ ] Transform to Div for block content
- [ ] Test `.pull-left[...]` and `.pull-right[...]`

**Success Criteria:** Block-level content works without `:::` fences

### Phase 5: Advanced Parsing (Milestone 5)
- [ ] Handle nested brackets: `.red[text with [brackets]]`
- [ ] Support multiple classes: `.red.bold[text]`
- [ ] Implement bracket counting algorithm
- [ ] Handle escaped characters
- [ ] Add comprehensive error handling

**Success Criteria:** Complex nested patterns work correctly

### Phase 6: Complete Utility Classes (Milestone 6)
- [ ] Implement all text color classes (9+ colors)
- [ ] Implement all background color classes
- [ ] Add typography utilities (sizes, weights, styles)
- [ ] Add layout utilities (.columns, .col, .center)
- [ ] Ensure WCAG AA accessibility compliance

**Success Criteria:** All utility classes render correctly

### Phase 7: Reveal.js Integration (Milestone 7)
- [ ] Implement `.fragment[...]` for incremental reveals
- [ ] Implement `.notes[...]` for speaker notes
- [ ] Test integration with Reveal.js features
- [ ] Verify proper class application

**Success Criteria:** Reveal.js features work seamlessly

### Phase 8: Documentation & Examples (Milestone 8)
- [ ] Write comprehensive README with all syntax examples
- [ ] Create example slides showcasing all features
- [ ] Add inline code comments
- [ ] Create troubleshooting guide
- [ ] Document differences from standard Quarto

**Success Criteria:** New users can install and use extension without assistance

### Phase 9: Polish & Release (Milestone 9)
- [ ] Add LICENSE file
- [ ] Comprehensive testing on example slides
- [ ] Test on multiple platforms (macOS, Linux, Windows)
- [ ] Version tagging (v0.1.0)
- [ ] Submit to Quarto extension registry (optional)

**Success Criteria:** Extension is production-ready

## Testing Strategy

### Manual Testing
- Create example slides using all features
- Test rendering in different browsers
- Verify accessibility with screen readers
- Check mobile/responsive rendering

### Edge Cases to Test
1. Nested brackets: `.red[outer [inner] text]`
2. Multiple classes: `.red.bold.large[text]`
3. Empty content: `.red[]`
4. Escaped brackets: `.red[text \[not-a-bracket\]]`
5. Adjacent patterns: `.red[one].blue[two]`
6. Within lists, tables, and code blocks
7. Unicode characters: `.red[你好]`

### Browser Compatibility
- Chrome/Chromium
- Firefox
- Safari
- Edge

## Technical Challenges & Solutions

### Challenge 1: Block vs. Inline Detection
**Problem:** Need to determine if `.class[content]` should become a Span (inline) or Div (block)

**Solution:**
- Parse bracketed content as markdown
- Check if parsed result contains block-level elements
- Heuristic: Multiple paragraphs OR non-Plain elements → Div, otherwise → Span
- Example: `.red[text]` → Span, `.pull-left[Para 1\n\nPara 2]` → Div

### Challenge 2: Parsing Nested Brackets
**Problem:** Lua pattern matching doesn't support recursive patterns for `.class[outer [inner] text]`

**Solution:** Implement bracket counting algorithm:
```lua
function findMatchingBracket(inlines, startPos)
  local depth = 0
  -- Count opening/closing brackets until depth returns to 0
  -- Return position of matching bracket
end
```

### Challenge 3: Processing Across Inline Elements
**Problem:** `.red[` might be one Str element, `text` another, `]` yet another

**Solution:**
- Process Inlines (list of inline elements) rather than individual Str elements
- Scan forward to find complete pattern across multiple elements
- Reassemble content from matched range

### Challenge 4: Multi-class Syntax
**Problem:** `.red.bold[text]` needs to parse multiple classes

**Solution:**
- Pattern match: `^%.([%w_-]+)` repeatedly
- Collect all class names before `[`
- Apply all classes to resulting Span/Div

### Challenge 5: Slide Separator in Code Blocks
**Problem:** `---` in code blocks shouldn't become slide breaks

**Solution:**
- Pandoc AST already distinguishes CodeBlock from HorizontalRule
- Only transform HorizontalRule elements
- Code blocks remain untouched

### Challenge 6: Performance
**Problem:** Parsing all inline content could be slow for large documents

**Solution:**
- Only process strings containing `.` at start
- Early exit if pattern not found
- Consider caching parsed results

### Challenge 7: Conflicting with Native Markdown
**Problem:** `.` could conflict with other syntax (e.g., end of sentence)

**Solution:**
- Require class name to start immediately after `.` with no space
- Require `[` immediately after class name
- Pattern is specific enough to avoid false positives

## Configuration Options (Future)

Allow users to customize via `_quarto.yml`:

```yaml
filters:
  - simpleslides

simpleslides:
  custom-colors:
    brand: "#2C8475"
    accent: "#E74C3C"
  disable-defaults: false
  custom-classes:
    - myclass
```

## Success Metrics

1. **Functionality:** All core features work as documented
2. **Usability:** Users can write colored text with <10 characters vs >30 in HTML
3. **Compatibility:** Works with existing Quarto slides without breaking changes
4. **Performance:** No noticeable rendering slowdown
5. **Documentation:** Clear examples and troubleshooting guide

## Future Enhancements (Post v1.0)

- Custom slide separators beyond `##`
- Keyboard shortcut hints in slides
- Print-friendly CSS
- Multiple color themes (light/dark mode aware)
- Integration with Quarto's built-in themes
- Shortcodes for common slide patterns (title slide, section divider, etc.)
- Support for background images with helper syntax
- Animation/transition helpers

## Resources

### Quarto Documentation
- [Creating Extensions](https://quarto.org/docs/extensions/creating.html)
- [Lua Filters](https://quarto.org/docs/extensions/filters.html)
- [Revealjs Format](https://quarto.org/docs/presentations/revealjs/)

### Lua/Pandoc
- [Pandoc Lua Filters](https://pandoc.org/lua-filters.html)
- [Pandoc AST](https://pandoc.org/lua-filters.html#type-inline)

### Inspiration
- [xaringan](https://github.com/yihui/xaringan)
- [remark.js](https://remarkjs.com/)

## Syntax Comparison Table

| Feature | Standard Quarto | simpleslides | Savings |
|---------|----------------|--------------|---------|
| **Slide break** | `## Slide Title` (36 chars) | `---` (3 chars) | 33 chars |
| **Colored text** | `<span style="color: red;">text</span>` (41 chars) | `.red[text]` (11 chars) | 30 chars |
| **Two columns** | `::: {.columns}` + `::: {.column}` × 2 + `:::` × 3 (60+ chars) | `.pull-left[...]` + `.pull-right[...]` (40 chars) | 20+ chars |
| **Fragments** | `::: {.fragment}` + content + `:::` (30+ chars) | `.fragment[content]` (20 chars) | 10+ chars |
| **Speaker notes** | `::: {.notes}` + content + `:::` (25+ chars) | `.notes[content]` (17 chars) | 8+ chars |
| **Header freedom** | `##` = slide break (can't use as header) | `##` = actual header! | ∞ |

**Total character savings:** 100+ characters per typical slide (30-40% reduction in markup overhead)

## Notes

- Keep syntax simple and intuitive
- Prioritize common use cases over edge cases
- Maintain backwards compatibility with standard Quarto (extension is additive, not breaking)
- Document any limitations clearly
- Consider accessibility in all design decisions
- xaringan users should feel immediately at home
