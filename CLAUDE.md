# nickymarino.com

Jekyll blog, deployed to GitHub Pages at https://nickymarino.com. The blog is the product —
there is no app, no marketing site, no docs.

## Design system

This repo has a companion **Claude Design** project: **Nicky Marino Blog**
(`61cdc570-e9b1-4c9b-9264-02089128097f`), viewable at https://claude.ai/design.

It is the source of truth for colors, type, spacing, and component styling. Reach it with the
`DesignSync` tool (`list_files` / `get_file` to read; writes go through `finalize_plan` first).
It was derived from this codebase — chiefly from `style-preview.html`, Nicky's own redesign
exploration, since deleted because the system supersedes it — so the two are meant to stay in step.

Its rules are also available as a skill:
[.claude/skills/nicky-marino-design/](.claude/skills/nicky-marino-design/SKILL.md). Invoke it
before styling work.

What lives there:

| Path | What |
| --- | --- |
| `tokens/` | `colors.css`, `typography.css`, `spacing.css`, `layout.css`, `elevation.css`, `motion.css`, `code.css`, `fonts.css` |
| `guidelines/` | 22 specimen cards (color ramps, type scale, spacing, radii, motion, brand) |
| `components/` | React primitives — `core/`, `layout/`, `content/`, each with `.jsx`, `.d.ts`, `.prompt.md` |
| `ui_kits/website/` | Click-through recreation of the site (home, post, archive, about) |
| `readme.md` | The written guidelines — voice, visual rules, what not to do |

### How it maps to this repo

The design tokens are mirrored into [_scss/tokens.scss](_scss/tokens.scss) as CSS custom
properties. **That file is the local copy of `tokens/` — when the design system changes, update
it, not the individual partials.** Everything else in `_scss/` consumes `var(--*)` and should
not hardcode a hex value.

| Design system | Here |
| --- | --- |
| `tokens/*.css` | [_scss/tokens.scss](_scss/tokens.scss) |
| `components/layout/Masthead` | [_scss/masthead.scss](_scss/masthead.scss) |
| `components/layout/Footer` | [_scss/footer.scss](_scss/footer.scss) |
| `components/content/PostCard`, `PostTitle`, `PostDate` | [_scss/post.scss](_scss/post.scss) |
| `components/core/Alert` | [_scss/alert.scss](_scss/alert.scss) |
| `components/content/CodeBlock`, `InlineCode` | [_scss/highlight.scss](_scss/highlight.scss), [_scss/container.scss](_scss/container.scss) |

### Rules worth remembering

- **One accent, one interactive hue.** Yellow is structural (masthead rule, link underline, hover
  color), blue is the resting link color and the code-block left flag. Nothing else is colored.
- **Light and dark.** Light is the default; dark applies under both `[data-theme="dark"]` and
  `prefers-color-scheme: dark`. There is no toggle — the site follows the OS.
- **Type.** Newsreader (serif) for display — masthead, post titles, headings. Manrope for body,
  meta, and UI. Body is 18px / 1.7. Mono is the system stack, no webfont.
- **Flat backgrounds only.** No gradients, textures, hero images, or illustration.
- **Motion is sparse.** 0.2s on link color and card lift, 0.3s on the theme swap. No entrance
  animations, no scroll reveals, no spring.
- **Icons are a capability, not a motif.** Open Iconic is vendored, but the live site uses exactly
  one glyph (`oi-link-intact`, marking a link post). Don't add more.
- **No emoji in prose.** The `jemoji` plugin exists; posts don't use it.

## Writing posts

First person, present tense, no throat-clearing — open with the point. Titles are plain
descriptions in title case, usually a task ("Install Ruby 2.7.3 on an M1 Mac"). Link generously
mid-sentence with the product's real name as the anchor, never "click here". Dates are long-form
("June 5, 2023"). Avoid marketing superlatives and "unlock/leverage/supercharge".

## Build

```bash
bundle exec jekyll serve --config _config.yml,_config_dev.yml
```

Sass lives in `_scss/` (configured via `sass_dir`); the entry point is
[public/css/styles.scss](public/css/styles.scss), which imports `base`, which imports everything
else. `poole.css` and `lanyon.css` are the original theme's stylesheets, kept for the bits not yet
replaced — they load *before* `styles.css` in [_includes/head.html](_includes/head.html) so our
own styles win the cascade. Don't reorder them.
