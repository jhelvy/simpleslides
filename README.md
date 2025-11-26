# simpleslides

A Quarto extension that makes creating Reveal.js presentations simpler and more intuitive.

**Authors:** John Paul Helveston, Pingfan Hu
**Version:** 0.1.0

## Features

- **Less typing:** 30-40% reduction in markup overhead
- **No more `:::`:** Use `.class[content]` instead of verbose fences
- **Colored text:** `.red[text]` instead of `<span style="color: red;">text</span>`
- **Headers work:** Use `---` for slides, `##` for actual headers
- **xaringan-inspired:** Familiar `.pull-left`/`.pull-right` syntax

## Installation

```bash
quarto add jhelvy/simpleslides
```

Or manually copy the `_extensions/simpleslides` folder to your project.

## Quick Start

Create a file `slides.qmd`:

```markdown
---
title: "My Presentation"
format: revealjs
filters:
  - simpleslides
---

---
# Welcome

This is my .red[first slide] with simpleslides!

---
# Features

.pull-left[
- Easy colors
- Simple layouts
- No `:::` fences
]

.pull-right[
.large.blue[Much easier!]
]
```

Render with:

```bash
quarto render slides.qmd
```

## Syntax Overview

### Slide Breaks

Use `---` (horizontal rule) to create new slides:

```markdown
---
# First Slide

---
# Second Slide
```

### Text Colors

Nine built-in colors:

```markdown
.red[text] .blue[text] .green[text]
.yellow[text] .orange[text] .purple[text]
.gray[text] .pink[text] .teal[text]
```

### Background Colors

```markdown
.bg-red[Highlighted text]
.bg-blue[Information box]
```

### Typography

```markdown
.large[Bigger] .small[Smaller] .huge[Huge!]
.bold[Bold] .italic[Italic] .underline[Underlined]
```

### Combining Classes

```markdown
.red.bold[Bold red text]
.large.blue[Large blue text]
```

### Two-Column Layout

```markdown
.pull-left[
Left content
]

.pull-right[
Right content
]
```

### Multi-Column Layout

```markdown
.columns[
.col[Column 1]
.col[Column 2]
.col[Column 3]
]
```

### Incremental Reveals

```markdown
.fragment[Appears on click]
```

### Speaker Notes

```markdown
.notes[
These are speaker notes
]
```

## Documentation

See [MANUAL.md](MANUAL.md) for complete documentation.

## Examples

See [example.qmd](example.qmd) for a comprehensive demonstration.

## Syntax Comparison

| Feature | Standard Quarto | simpleslides | Savings |
|---------|----------------|--------------|---------|
| Colored text | `<span style="color: red;">text</span>` (41 chars) | `.red[text]` (11 chars) | 73% |
| Two columns | `::: {.columns}` + nested `:::` (60+ chars) | `.pull-left[...]` (20 chars) | 67% |
| Fragments | `::: {.fragment}...:::` (30 chars) | `.fragment[...]` (17 chars) | 43% |

## Migrating from xaringan

Most xaringan syntax works directly:

- `---` for slides ✅
- `.red[text]` ✅
- `.pull-left[...]` and `.pull-right[...]` ✅

Main differences:
- Use `.notes[...]` instead of `???`
- Use `.center[...]` instead of `class: center, middle`

## Requirements

- Quarto 1.4 or later
- Reveal.js format

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Inspired by [xaringan](https://github.com/yihui/xaringan) by Yihui Xie
- Built on [Quarto](https://quarto.org) and [Reveal.js](https://revealjs.com)

## Contributing

Issues and pull requests welcome!

## Support

For issues or questions:
- [GitHub Issues](https://github.com/jhelvy/simpleslides/issues)
- See [MANUAL.md](MANUAL.md) for detailed documentation
- Check [example.qmd](example.qmd) for working examples
