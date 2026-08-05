# Nicky Marino — Design System

> Mirrored from `readme.md` in the "Nicky Marino Blog" Claude Design project
> (`61cdc570-e9b1-4c9b-9264-02089128097f`). Re-fetch with `DesignSync` if the project changes.
> Paths in the tables below are paths *within the design project*, not this repo — see
> [../SKILL.md](../SKILL.md) for the mapping to `_scss/`.

Nicky Marino's personal website and blog at **nickymarino.com**. One product, one surface: a
static Jekyll site with a home feed, individual posts, a year-grouped archive, an about page, and
a resume PDF. There is no app, no marketing site, no docs site. The blog *is* the product.

## Two eras, reconciled

The old Jekyll site was **dark-only** (`#121212`, Lato/Roboto, `#FFD54F` yellow rules, Monokai
code). `style-preview.html` was the **new direction** — light and dark, Manrope, blue links,
yellow on hover, post cards, GitHub-style syntax colors, annotated "LMNT exact colors" and
"inspired by arun.is". This system ships the new direction and keeps the old values as named
tokens (`--yellow-400` *was* `$color-primary`; `--monokai-*` is preserved for archival posts).

Reference site: `https://lmnt.me/` (Louie Mantia). Borrowed: the dark navy ground, bright blue
links, yellow hover, plain-index density. Not borrowed: LMNT's badges, illustration, playfulness.

---

## Content fundamentals

**First person, present tense, no throat-clearing.** Posts open with the point, often bolded:

> **I'm going to strengthen my fullstack serverless developer skills by building a clone of bitly.**

**"I" for the author, "you" for the reader — and the reader is a peer.** Never "we" as a corporate
plural. Nicky explains what *he* did and why, then hands over the commands.

**Titles are plain descriptions, in title case, usually a task.** "Install Ruby 2.7.3 on an M1
Mac". "Fix Liquid Syntax Errors". "Remove Non-Master Local Branches". Occasionally a wry one:
"Shorty 09: From Many, a Monopackage", "A New Look". No clickbait, no colons-with-a-promise, no
"The Ultimate Guide to".

**Sentence case for headings inside a post,** with title case for section headers that read like
chapter names: "A Foray into Developer Journals", "Architecture Overview".

**Casual asides are allowed, briefly.** One personality beat per post, not a running bit.

**Link generously, mid-sentence, with the product's real name as the anchor.** Posts routinely
carry a dozen inline reference links. Anchors are nouns, never "click here" and never a bare URL.

**Dates are long-form:** "June 5, 2023" — full month, no leading zero, no ordinal.

**No emoji in prose.** The site *supports* emoji (the `jemoji` plugin and an `img.emoji` rule
exist) but posts don't use them.

**Enthusiasm is earned, not performed.** Sign-offs like "I'm really excited to embark on this
journey" appear at the end of a substantial plan, not at the top of a tip post.

**Copy to avoid:** marketing superlatives, "unlock/leverage/supercharge", rhetorical questions as
headings, "here's why this matters", em-dash-heavy aphorisms, second-person imperatives that
assume the reader's goals ("You need a URL shortener").

---

## Visual foundations

**Color.** One accent (yellow), one interactive hue (blue), and a navy↔paper neutral axis.
Yellow is *structural*, not decorative: it draws the 4px rule under the masthead, underlines
links, and is the hover color for every link. Blue is the resting link color and the left flag on
code blocks. Nothing else is colored. Light mode grounds on `#FAFAF9` with white cards; dark mode
grounds on `#0D1217` with `#1A2332` cards. Theming is `[data-theme="dark"]` plus a
`prefers-color-scheme` fallback — the live site has no toggle, it follows the OS.

**Type.** Two families. **Newsreader** (serif) for display type — masthead, post titles, section
headings; **Manrope** for body, meta, and UI. Body is **18px at 1.7 line-height**, which is
generous and deliberate; the reading measure caps at 46rem. Headings run 700 (masthead, post
titles) down to 600 (section headings) and stay at 1.2 line-height. Mono is the system stack
(Menlo, Monaco) — no webfont for code. Uppercase + 0.05em tracking appears only on footer column
labels and code-language eyebrows.

**Spacing.** A 0.25rem base doubling to 4rem. In practice three numbers do most of the work: 1rem
between paragraphs, 2rem of card padding, 3rem between cards.

**Backgrounds.** Flat color, always. No gradients, no textures, no patterns, no full-bleed
photography, no hero imagery, no illustration. The page is a single centered column on a flat
ground.

**Cards.** The post card is the only card: `--surface-card`, 8px radius, `0 4px 6px` shadow, no
border. On hover it lifts `translateY(-2px)` and the shadow deepens to `0 8px 12px`. In dark mode
the shadow is stronger (30% → 40% black) because the surface contrast is lower. Code blocks are
the one bordered surface: 1.5px hairline plus a 4px blue left flag.

**Borders and rules.** 4px yellow under the masthead (radius 2px). 1.5px hairline above the
footer. 0.25rem grey left rule on quotes. 2px outline on alerts. 1.5px yellow link underline at
3px offset.

**Shadows.** Two outer shadows only (`--shadow-card`, `--shadow-card-hover`). No inset shadows,
no glows, no colored shadows.

**Radii.** 3px inline code → 5px small chips → 6px code blocks and images → 8px cards. Pills only
for the theme control. Nothing is a circle.

**Animation.** Sparse and short. 0.2s ease on link color and card lift; 0.3s ease on the
background/text swap when the theme changes. No entrance animations, no scroll-triggered reveals,
no bounce, no spring, no stagger. Respect `prefers-reduced-motion` by simply having little to
reduce.

**Hover states.** Links go blue → yellow, and the underline goes yellow with them. Nav and footer
links have no underline at rest and change color only. Cards lift. **Press states:** none — the
site has no buttons. If you must add a button, darken/lighten the fill by one ramp step and do not
scale it.

**Transparency and blur.** Neither. No frosted headers, no scrims, no protection gradients — the
column-on-flat-ground layout never puts text over an image. The one alpha value in the system is
the dark-mode selection highlight (`--selection-bg`, 28% yellow).

**Layout.** Nothing is fixed or sticky. One column, centered, stepping 28 → 32 → 38 → 46rem across
four breakpoints (base, 38em, 56em, 100em). Masthead and footer share the column, so their rules
align with the content edge. Footer is sticky-to-bottom via flex, not position.

**Imagery.** Screenshots and diagrams from posts, nothing else. They are UI captures — cool,
neutral, mostly dark-chrome editor windows — not photography. No grain, no duotone, no color
treatment. Images span the full measure at 6px radius; captions are 0.875em muted.

---

## Iconography

**Open Iconic, as a real vendored font.** The Jekyll site ships `public/open-iconic/font/` and
loads `open-iconic-bootstrap.min.css`. Glyphs are used as `<span class="oi oi-link-intact">`.
Open Iconic is a 223-glyph, single-weight, solid-ish outline set at 8×8px native grid; it reads as
slightly chunky and utilitarian, which suits the site.

**Actual usage in the source is nearly zero.** One glyph, `oi-link-intact`, marks a link post on
the home feed (`_includes/link-icon.html`). That is the whole icon vocabulary of the live site.
Icons are therefore a *capability*, not a motif — use them for the link-post marker, RSS, and the
theme control, and nowhere else.

**Unicode as icons:** yes, sparingly. External footer links append `↗` via `::after`; pagination
uses `→`.

**No SVG icon set exists, and none was drawn.** No CDN icon library is linked.

## Brand marks

**There is no logo or wordmark.** The repo contains only favicon-family assets:
`safari-pinned-tab.svg` (a monochrome pinned-tab glyph), `apple-touch-icon.png`,
`android-chrome-256x256.png`, `favicon-32x32.png`, `favicon.ico`. Wherever a mark would go, set
**Nicky Marino** in Newsreader 700 — which is what the masthead does.

---

## What's in the design project

| Path | What |
| --- | --- |
| `styles.css` | Global entry point. `@import` list only. |
| `tokens/` | `colors.css`, `typography.css`, `spacing.css`, `layout.css`, `elevation.css`, `motion.css`, `code.css`, `fonts.css` |
| `guidelines/` | 22 specimen cards for the Design System tab |
| `components/` | React primitives — see below |
| `ui_kits/website/` | Click-through recreation of nickymarino.com (4 screens) |
| `templates/blog-post/` | Starting template: a full post page |
| `assets/brand/` | Favicons and the pinned-tab glyph (no logo exists) |
| `assets/open-iconic/` | The Open Iconic font binaries and CSS |

### Components

Each has a `.jsx`, a `.d.ts` props contract, and a `.prompt.md` usage note.

**`components/core/`**
- `Link` — inline link; variants `default` / `plain` / `nav` / `footer`, `external` adds ↗
- `Icon` — Open Iconic glyph wrapper
- `Alert` — outlined inline notice for post asides

**`components/layout/`**
- `Wrap` — the centered reading measure
- `Masthead` — site header with the 4px yellow rule
- `Footer` — muted link columns plus a note

**`components/content/`**
- `PostCard` — the primary content unit; lifts on hover
- `PostTitle` — headline, optional chain glyph for link posts
- `PostDate` — long-form date line
- `CoverImage` — full-measure image with optional caption
- `Blockquote` — quote behind a grey left rule
- `CodeBlock` — token-highlighted code with a blue left flag
- `InlineCode` — monospace snippet in prose
- `ArchiveList` — posts grouped by year

### Substitutions to confirm

- **Manrope** and **Newsreader** load from Google Fonts, not vendored — the repo has no font
  binaries. `style-preview.html` picked Manrope for body; Newsreader for headings was chosen in
  review. Self-hosting would be better. `about.md` still claims the site is "typeset in Lora";
  the old site actually loaded Lato + Roboto. Neither is carried forward.
- **`--font-mono`** is `Menlo, Monaco, monospace`. The old `_scss/typography.scss` also listed
  `'Lucida Sans Typewriter'`; dropped as a local-only system face with no font file to ship.
  Rendering is unchanged on macOS, where Menlo resolves first.
