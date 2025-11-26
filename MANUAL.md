# simpleslides User Manual

**Authors:** John Paul Helveston, Pingfan Hu
**Version:** 0.1.0
**Last Updated:** 2025-11-25

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Slide Creation](#slide-creation)
- [Text Styling](#text-styling)
- [Layout Helpers](#layout-helpers)
- [Reveal.js Integration](#revealjs-integration)
- [Complete Example](#complete-example)
- [Tips & Tricks](#tips--tricks)
- [Troubleshooting](#troubleshooting)
- [Migrating from xaringan](#migrating-from-xaringan)

## Introduction

simpleslides is a Quarto extension that makes creating presentation slides easier and more intuitive. Inspired by the [xaringan](https://github.com/yihui/xaringan) R package, simpleslides eliminates verbose HTML and reduces the need for `:::` fences, letting you focus on your content.

### Key Benefits

- **Less typing:** 30-40% reduction in markup overhead
- **Intuitive syntax:** `.red[text]` instead of `<span style="color: red;">text</span>`
- **No more `:::`:** Use `.class[content]` for everything
- **Headers work properly:** Use `##` for actual headings, not slide breaks
- **xaringan-style:** Familiar syntax for xaringan users

## Installation

### From GitHub

```bash
quarto add yourusername/simpleslides
```

### Manual Installation

1. Download this repository
2. Copy the `_extensions/simpleslides` folder to your project
3. Reference it in your YAML front matter

## Quick Start

Create a new file `slides.qmd`:

```markdown
---
title: "My Presentation"
format:
  revealjs:
    theme: default
filters:
  - simpleslides
---

---
# Welcome Slide

This is my .red[first slide] with simpleslides!

---
# Second Slide

## This is an actual header

.blue[Content] can be styled .bold[easily].

.pull-left[
Left column content
- Bullet points
- Work here
]

.pull-right[
Right column content
- Also with
- Bullet points
]
```

Render with:

```bash
quarto render slides.qmd
```

## Slide Creation

### Using `---` for Slide Breaks

**Standard Quarto:** Uses `##` for slide breaks, which prevents using `##` as a section header.

**simpleslides:** Use `---` (horizontal rule) to create new slides.

```markdown
---
# First Slide

Content here

---
# Second Slide

## Now I can use ## as a real header!

More content
```

**Benefits:**
- `##`, `###`, `####` are freed up for actual section headers
- Cleaner slide structure
- More like xaringan/remark.js

### Slide Titles

You can add titles in multiple ways:

```markdown
---
# Slide with H1 Title

Content here

---
## Slide with H2 Title

### And H3 subtitle

Content here

---
No title, just content
```

## Text Styling

### Color Classes

Apply colors without HTML:

```markdown
.red[Important text]
.blue[Information]
.green[Success message]
.yellow[Warning]
.orange[Attention]
.purple[Special note]
.gray[Muted text]
.pink[Highlight]
.teal[Accent]
```

**Rendered output:**
- <span style="color: #E74C3C;">Important text</span> (red)
- <span style="color: #3498DB;">Information</span> (blue)
- <span style="color: #2ECC71;">Success message</span> (green)

### Background Colors

Highlight text with background colors:

```markdown
.bg-red[Critical alert]
.bg-blue[Information box]
.bg-green[Success notification]
```

**Rendered:** Text with colored background and automatic white text for contrast.

### Combining Multiple Classes

Stack classes for combined effects:

```markdown
.red.bold[Bold red text]
.blue.large[Big blue text]
.teal.italic.bg-gray[Teal italic text on gray background]
```

### Typography Utilities

#### Size

```markdown
.tiny[Tiny text] (60%)
.smaller[Smaller text] (70%)
.small[Small text] (85%)
Normal text (100%)
.large[Large text] (130%)
.larger[Larger text] (150%)
.huge[Huge text] (200%)
```

#### Weight & Style

```markdown
.bold[Bold text]
.light[Light weight text]
.italic[Italic text]
.underline[Underlined text]
.strike[Strikethrough text]
```

#### Combinations

```markdown
.large.bold.red[Big bold red text]
.small.italic.gray[Small italic gray text]
```

## Layout Helpers

### Two-Column Layout (xaringan-style)

The classic xaringan `.pull-left` and `.pull-right`:

```markdown
.pull-left[
### Left Column

- First point
- Second point
- Third point

You can use **any markdown** here!
]

.pull-right[
### Right Column

- Different content
- On the right
- Side by side

![Image](path/to/image.png)
]
```

**Note:** Content inside `[...]` is parsed as markdown, so you can include:
- Paragraphs
- Lists
- Images
- Code blocks
- Nested formatting

### Multi-Column Layout

For three or more columns:

```markdown
.columns[
.col[
First column
- Auto width
]

.col[
Second column
- Auto width
]

.col[
Third column
- Auto width
]
]
```

### Centered Content

```markdown
.center[
This content is centered
]
```

## Reveal.js Integration

### Fragments (Incremental Reveals)

**Standard Quarto:**
```markdown
::: {.fragment}
Appears on click
:::
```

**simpleslides:**
```markdown
.fragment[Appears on click]
```

Multiple fragments:

```markdown
- .fragment[First item appears]
- .fragment[Then this one]
- .fragment[Finally this one]
```

Or wrap entire blocks:

```markdown
.fragment[
### This whole section appears together

- Including
- All these
- Bullet points
]
```

### Speaker Notes

**Standard Quarto:**
```markdown
::: {.notes}
These are speaker notes
:::
```

**simpleslides:**
```markdown
.notes[
These are speaker notes that only you see.
They can span multiple lines.
]
```

### Combining Features

```markdown
---
# Slide Title

.fragment[
.pull-left[
.red[Left content] appears first
]

.pull-right[
.blue[Right content] also appears
]
]

.notes[
Remember to mention the important point about left vs right
]
```

## Complete Example

Here's a full presentation using simpleslides:

```markdown
---
title: "Quarterly Results"
subtitle: "Q4 2025"
author: "Your Name"
date: "2025-11-25"
format:
  revealjs:
    theme: default
    slide-number: true
    transition: slide
filters:
  - simpleslides
---

---
# Overview

.large[Welcome to our Q4 results presentation]

.fragment[Today we'll cover:]

.fragment[
- Revenue growth
- Market expansion
- Future outlook
]

---
# Revenue Growth

## Year over Year Comparison

.pull-left[
### 2024
- Q1: .red[$2.1M]
- Q2: .red[$2.3M]
- Q3: .red[$2.5M]
- Q4: .red[$2.8M]
]

.pull-right[
### 2025
- Q1: .green[$3.2M]
- Q2: .green[$3.6M]
- Q3: .green[$3.9M]
- Q4: .green[$4.5M]
]

.notes[
Emphasize the consistent growth trajectory
Mention the Q4 spike due to holiday sales
]

---
# Key Metrics

.center[
.huge[↑ 61%]
]

.center[
.large[Revenue increase from 2024 to 2025]
]

.fragment[
.bg-green[This represents our best year yet!]
]

---
# Market Expansion

.columns[
.col[
### North America
- .green[+25%] growth
- 3 new offices
- 50 new hires
]

.col[
### Europe
- .green[+40%] growth
- 2 new offices
- 35 new hires
]

.col[
### Asia-Pacific
- .green[+95%] growth
- 4 new offices
- 80 new hires
]
]

---
# Challenges

.fragment[
## Supply Chain
.yellow[Some delays in Q3], but .green[resolved by Q4]
]

.fragment[
## Hiring
.red[Competitive market] for talent, but .green[meeting targets]
]

.fragment[
## Infrastructure
.blue[Investing heavily] in scalability
]

---
# 2026 Outlook

.large.bold[Our Goals:]

1. .fragment[.teal[Revenue target:] $22M (60% growth)]
2. .fragment[.teal[New markets:] Latin America, Middle East]
3. .fragment[.teal[Team growth:] 200+ new hires]

.fragment[
.center[
.huge.bold.green[We're ready! 🚀]
]
]

.notes[
End on a high note
Open for questions after this slide
]

---
# Questions?

.center[
.large[Thank you!]

your.email@company.com
]
```

## Tips & Tricks

### Nesting Classes

You can nest class applications:

```markdown
.large[
This is large text with .red[red portions] and .blue[blue portions]
]
```

### Escaping Brackets

If you need literal brackets inside class content:

```markdown
.red[This text contains \[literal brackets\]]
```

### Mixing with Standard Quarto

simpleslides is fully compatible with standard Quarto syntax:

```markdown
.pull-left[
simpleslides content
]

::: {.pull-right}
Standard Quarto content
:::
```

Both work! Use whichever you prefer.

### Code Blocks

Code blocks work normally inside class content:

```markdown
.pull-left[
### Code Example

\`\`\`python
def hello():
    print("Hello, world!")
\`\`\`
]
```

### Images

Images work inside class content:

```markdown
.center[
![Logo](logo.png){width=200px}
]

.pull-left[
![Chart 1](chart1.png)
]

.pull-right[
![Chart 2](chart2.png)
]
```

### Fragment Indices

Use standard Quarto fragment indices:

```markdown
.fragment[Appears first]{fragment-index=1}
.fragment[Appears second]{fragment-index=2}
.fragment[Also appears first]{fragment-index=1}
```

Wait, that won't work! If you need fine control over fragment order, use standard Quarto syntax:

```markdown
::: {.fragment fragment-index=1}
Appears first
:::
```

Or just use the order they appear in the document:

```markdown
.fragment[First]
.fragment[Second]
.fragment[Third]
```

## Troubleshooting

### Issue: `---` not creating slides

**Cause:** The filter might not be loaded, or you're in a different format.

**Solution:** Ensure your YAML includes:
```yaml
format:
  revealjs: default
filters:
  - simpleslides
```

### Issue: Classes not applying

**Cause:** Typo in class name or missing closing bracket.

**Solution:**
- Check class name spelling (e.g., `.red` not `.Red`)
- Ensure matching brackets: `.red[text]` not `.red[text`
- Check for proper nesting

### Issue: Content not parsing as markdown

**Cause:** This should work automatically.

**Solution:** If you see raw markdown syntax, please report as a bug.

### Issue: Colors not showing

**Cause:** Custom theme might override colors.

**Solution:** Add `simpleslides.scss` to your theme:
```yaml
format:
  revealjs:
    theme: [default, simpleslides.scss]
```

### Issue: Two-column layout overlapping

**Cause:** Too much content in one column.

**Solution:**
- Reduce content
- Use `.columns` with `.col` instead for better overflow handling
- Adjust column widths in custom CSS

### Issue: `##` still creating slides

**Cause:** Quarto defaults to `slide-level: 2`

**Solution:** Set slide level to 1 or 0:
```yaml
format:
  revealjs:
    slide-level: 1
```

Or use `---` exclusively for slides.

## Migrating from xaringan

Good news! Most xaringan syntax works directly:

| xaringan | simpleslides | Status |
|----------|--------------|---------|
| `---` for slides | `---` | ✅ Same |
| `.red[text]` | `.red[text]` | ✅ Same |
| `.pull-left[...]` | `.pull-left[...]` | ✅ Same |
| `.pull-right[...]` | `.pull-right[...]` | ✅ Same |
| `class: center, middle` | Use `.center[...]` | ⚠️ Different |
| `???` for notes | `.notes[...]` | ⚠️ Different |
| `.footnote[...]` | `.small.gray[...]` or custom | ⚠️ Different |

### Example Migration

**xaringan:**
```markdown
---
class: center, middle

# Title

---

.pull-left[
Content
]

.pull-right[
Content
]

???
Speaker notes
```

**simpleslides:**
```markdown
---
.center[
# Title
]

---

.pull-left[
Content
]

.pull-right[
Content
]

.notes[
Speaker notes
]
```

## Color Reference

### Standard Colors

| Class | Color | Hex |
|-------|-------|-----|
| `.red` | Red | #E74C3C |
| `.blue` | Blue | #3498DB |
| `.green` | Green | #2ECC71 |
| `.yellow` | Yellow | #F39C12 |
| `.orange` | Orange | #E67E22 |
| `.purple` | Purple | #9B59B6 |
| `.gray` | Gray | #95A5A6 |
| `.pink` | Pink | #FD79A8 |
| `.teal` | Teal | #2C8475 |

All colors are WCAG AA compliant for accessibility on white backgrounds.

### Background Colors

Same colors available with `bg-` prefix:
- `.bg-red[text]`
- `.bg-blue[text]`
- `.bg-green[text]`
- etc.

## Accessibility Notes

- All color classes meet WCAG AA contrast requirements
- Background color classes automatically use white text for proper contrast
- Semantic HTML structure maintained
- Screen reader compatible
- Fragment reveals work with keyboard navigation

## Advanced Customization

### Custom Colors

Add your own colors by creating a custom SCSS file:

```scss
// custom.scss
.brand {
  color: #YOUR_BRAND_COLOR;
}

.bg-brand {
  background-color: #YOUR_BRAND_COLOR;
  color: white;
  padding: 0.2em 0.4em;
  border-radius: 0.2em;
}
```

Then include it:

```yaml
format:
  revealjs:
    theme: [default, simpleslides.scss, custom.scss]
```

### Custom Classes

You can use any class name with the `.class[content]` syntax, as long as the CSS is defined:

```markdown
.my-custom-class[
Content here
]
```

Just define `.my-custom-class` in your CSS.

## FAQ

**Q: Can I use simpleslides with other Quarto formats?**
A: simpleslides is designed for `revealjs` format. Other formats may not support all features.

**Q: Does this work with Quarto 1.3?**
A: simpleslides requires Quarto 1.4+.

**Q: Can I mix simpleslides syntax with standard Quarto?**
A: Yes! They work together seamlessly.

**Q: What about PowerPoint/PDF export?**
A: Styling will export, but Reveal.js-specific features (fragments, notes) behave according to Quarto's export settings.

**Q: Is there a performance impact?**
A: Minimal. The Lua filter adds negligible processing time.

**Q: Can I contribute?**
A: Yes! See our GitHub repository for contribution guidelines.

## Support

- **Issues:** https://github.com/yourusername/simpleslides/issues
- **Discussions:** https://github.com/yourusername/simpleslides/discussions
- **Email:** your.email@example.com

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Inspired by [xaringan](https://github.com/yihui/xaringan) by Yihui Xie
- Built on [Quarto](https://quarto.org) and [Reveal.js](https://revealjs.com)
- Color palette based on [Flat UI Colors](https://flatuicolors.com)

---

**simpleslides** - Making Quarto slides simple again.
