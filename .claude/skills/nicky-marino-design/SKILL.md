---
name: nicky-marino-design
description: Design guidelines for Nicky Marino's website and blog — colors, type, spacing, components, and voice. Use when styling or restyling any part of this site, when adding a new component or page, when building a throwaway mock or prototype of the site, or when writing post copy. Also use before changing anything in _scss/.
---

# Nicky Marino — design system

The canonical source is the **Nicky Marino Blog** Claude Design project
(`61cdc570-e9b1-4c9b-9264-02089128097f`), readable with the `DesignSync` tool. This skill is the
working copy of its rules; [reference/design-system.md](reference/design-system.md) is the full
written guide, mirrored from the project's `readme.md`.

## Start here

**Never hardcode a color, size, or duration.** Every value lives in
[_scss/tokens.scss](../../../_scss/tokens.scss) as a CSS custom property — that file is the local
mirror of the design project's `tokens/` folder. Read it before you write any CSS. If a value you
need isn't there, that's a signal to check the design project rather than invent one.

For production styling, edit the partial that owns the concern:

| Concern | File |
| --- | --- |
| Tokens (the only place hexes live) | `_scss/tokens.scss` |
| Type mixins | `_scss/typography.scss` |
| Link treatments | `_scss/mixins.scss` |
| Body, headings, quotes, images, `.wrap` | `_scss/base.scss` |
| Site header | `_scss/masthead.scss` |
| Post cards, titles, dates | `_scss/post.scss` |
| Footer columns | `_scss/footer.scss` |
| Prose links, inline + block code | `_scss/container.scss` |
| Post asides | `_scss/alert.scss` |
| Rouge syntax colors | `_scss/highlight.scss` |

For a mock or prototype, write a standalone HTML file with the tokens inlined in a `<style>`
block. Don't add a build step.

## The rules

**Color.** One accent (yellow), one interactive hue (blue), a navy↔paper neutral axis. Yellow is
*structural*, not decorative — the 4px masthead rule, link underlines, and the hover color for
every link. Blue is the resting link color and the code-block left flag. **Nothing else is
colored.** Light grounds on `--paper-050` with white cards; dark grounds on `--navy-900` with
`--navy-700` cards.

**Theming.** Light is the default. Dark applies under both `[data-theme="dark"]` and
`prefers-color-scheme: dark`. There is no toggle — the site follows the OS. Any new component
must be checked in both.

**Type.** Newsreader (serif) for display — masthead, post titles, section headings. Manrope for
body, meta, and UI. Body is 18px at 1.7. Headings run 700 down to 600 at 1.2 line-height. Mono is
the system stack; no webfont for code. Uppercase + `--tracking-caps` appears *only* on footer
column labels and code-language eyebrows.

**Spacing.** Three numbers do most of the work: 1rem between paragraphs, 2rem of card padding,
3rem between cards.

**Cards.** The post card is the only card: `--surface-card`, 8px radius, `--shadow-card`, no
border. Hover lifts it `translateY(-2px)`. Code blocks are the one bordered surface — a 1.5px
hairline plus a 4px blue left flag.

**Radii.** 3px inline code → 5px chips → 6px code blocks and images → 8px cards. Nothing is a
circle.

**Motion.** 0.2s on link color and card lift, 0.3s on the theme swap. That's the whole vocabulary.

**Layout.** One centered column stepping 28 → 32 → 38 → 46rem across four breakpoints. Nothing is
fixed or sticky. The footer sticks to the bottom via flex, not `position`.

**Icons.** Open Iconic is vendored, but the live site uses exactly one glyph —
`oi-link-intact`, marking a link post. Treat icons as a capability, not a motif.

## Don't

- Gradients, textures, patterns, hero imagery, or illustration — backgrounds are flat color
- Transparency or blur; no frosted headers, no scrims
- Inset shadows, glows, or colored shadows
- Entrance animations, scroll-triggered reveals, bounce, spring, or stagger
- Emoji in prose (the `jemoji` plugin exists; posts don't use it)
- A second accent color, or coloring anything that isn't a link

## Voice

First person, present tense, no throat-clearing — open with the point. "I" for the author, "you"
for the reader, and the reader is a peer; never a corporate "we". Titles are plain descriptions in
title case, usually a task. Link generously mid-sentence with the product's real name as the
anchor — never "click here", never a bare URL. Dates are long-form ("June 5, 2023"). One
personality beat per post, not a running bit.

Avoid: marketing superlatives, "unlock/leverage/supercharge", rhetorical questions as headings,
"here's why this matters", and second-person imperatives that assume the reader's goals.
