# wiauxb-theme

A [Touying](https://touying-typ.github.io/) slide theme.
Catppuccin colors, Roboto + JetBrainsMono, progress-bar frame titles,
shadowed blocks, native syntax-highlighted code boxes, stickers and timelines.

See [`examples/showcase.typ`](examples/showcase.typ) for every feature on one deck.

## Install (local package)

Typst can't fetch packages from git, so clone the repo and install from it:

```sh
git clone <repo-url> ~/src/wiauxb-theme
~/src/wiauxb-theme/install.sh          # latest release
```

Then, in any deck, anywhere on disk:

```typ
#import "@local/wiauxb-theme:0.1.0": *
```

Imports pin an exact version: a deck keeps using the version it names until
you edit its import, even after newer ones are installed. To get a new
release, `git pull` then `./install.sh` again (or `./install.sh 0.1.1`,
`./install.sh --all`). See [`CHANGELOG.md`](CHANGELOG.md) for what changed
between versions.

Each release is installed as a frozen copy of its git tag, in Typst's local
package directory (Linux: `~/.local/share/typst/packages/local/`, macOS:
`~/Library/Application Support/typst/packages/local/`). The script needs
`sh` and `git`. On Windows (untested), run it from Git Bash with `TYPST_PACKAGE_PATH`
set to `%APPDATA%\typst\packages`.

`@local` packages work with the Typst CLI and Tinymist (VS Code), but not in
the typst.app web editor.

### Prerequisites

- **Typst** ≥ 0.13 (developed on 0.14.2).
- **Fonts**, installed on your machine (packages can't ship fonts): `Roboto`
  and a JetBrains Mono Nerd Font (Typst sees it as `JetBrainsMono NFM`). Check
  with `typst fonts`. Other fonts: `font:` / `mono-font:` / `icon-font:`
  options of `wiauxb-theme` (the icon font must be a Nerd Font).
- Internet on first compile: Typst downloads the dependencies (`touying`,
  `catppuccin`, `showybox`, `cetz`) from Typst Universe into its cache.

## Start a new deck

```sh
typst init @local/wiauxb-theme:0.1.0 my-talk
cd my-talk && typst watch main.typ
```

This copies [`template/main.typ`](template/main.typ): title, outline, a
section and a frame.

### File paths

A package can't read files from your project, so anything that loads a file
takes the loaded content, not a path:

```typ
#codefile(read("src/main.rs"), name: "main.rs")   // not codefile("src/main.rs")
#sticker(image("images/meme.png"))               // not sticker("images/meme.png")
```

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md): how to test changes with a dev
install, what version to bump, and how to cut a release.

## Minimal deck

```typ
#import "@local/wiauxb-theme:0.1.0": *

#show: wiauxb-theme.with(
  // dark: true,            // Macchiato instead of Latte
  accent: "blue",           // any Catppuccin color name, or omit -> auto
  secondary: "maroon",
  config-info(
    title:    [My talk],
    subtitle: [An optional subtitle],
    author:   [Bastien Wiaux],
    date:     datetime.today().display(),
    logo:     image("logo.png"),   // footer (small) + title slide (larger)
  ),
)

#title-slide()

= A section            // appears in the outline + footer; does NOT make a slide
== A frame title       // each "==" starts a new slide
Body text here.
```

### Some "quirks" (because I like the aesthetics of it)

These standard markups are **recolored**, exactly like in the Beamer theme:

- `*bold*` → **accent** color
- `_italic_` → accent color, italic
- `` `inline code` `` → a subtle code "chip" (tinted background, neutral text).
  Single backticks have no language. For a *highlighted* inline snippet use
  triple backticks on one line — ` ```rust let x = 1``` ` — or the raw
  function — `#raw("let x = 1", lang: "rust")`.

## Overlays / incremental reveal

Touying handles this natively:

```typ
== Reveal step by step
First line. #pause
Second line appears next. #pause
Third line.
```

```typ
Always here.
#uncover("2-")[appears from subslide 2, but reserves its space]
#only("3")[only on subslide 3, reserves no space]
#alternatives[shown on 1][shown on 2]
```

Overlay specs are like LateX Beamer: `"2-"`, `"2-3"`, `"1,3-"`, or a bare int.

## Customizing

- **Colors**: any Catppuccin name works for `accent`/`secondary`:
  `rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender`.
- **Logo**: pass `logo: image("logo.png")` — the theme auto-fits it to each
  slot (small in the footer, larger on the title slide), so you don't size it
  yourself. (Typst idiom: a bare `image()` fills 100% of its container width
  and overflows; the theme's `fit-height` helper scales it to a fixed height
  instead. Tune those heights — `0.8cm` footer, `1.2cm` title — in `lib.typ`.)
- **Multiple logos**: wrap them with the `logos(...)` helper — they're laid out
  in one row and fitted together:
  ```typ
  logo: logos(
    image("uclouvain.svg", height: 1em),
    image("hexrays.svg",   height: 1em),
  )            // `gap:` controls spacing; only the relative heights matter
  ```
- **Vertically center slide bodies**: pass `center-body: true` to
  `wiauxb-theme.with(...)`. The frame title stays at the top and the footer at
  the bottom; only the body is centered between them. Per-slide override:
  `#slide(setting: body => align(top, body))[...]`.
- **Base font size**: edit `set text(... size: 22pt)` in `lib.typ` (`init`).
- **Sections** (`= X`) never produce a slide — they only populate the outline
  and the footer. For a standalone big centered title card, use
  `#focus-slide[Big text]` wherever you want one.
- **Shadow / corners**: tweak `_shadow()` and the `radius:` fields in
  `lib.typ`.

## Notes

Timelines: `active:` controls how much is highlighted — `N` (first N entries),
`-1` (all, the default), or `auto` (advances with subslides, so one call
animates). Vertical entries are dicts `(title:, desc:, icon:)`; `desc`/`icon`
are optional. `htimeline-dates` entries are years or `(year, label)` pairs;
labels show above a dot only when they differ from the year.

Accordion notes: `reveal:` takes an overlay spec (`"2-"`, `"3"`, `"2-4"`);
omit it for an always-open block. A collapsed block shows its title bar plus a
small empty body strip (showybox always draws a body section).

Figures use the explicit `#framed-image(...)` helper rather than auto-wrapping
every image (that would also frame the logos). White card by default; override
with `fill: none` (transparent), `fill: auto` (theme base), or any color.

Code blocks wrap long lines at spaces and break inside long unbroken tokens
(Beamer breaklines/breakanywhere) — handy for long config/regex lines.

Behavioral notes:

- An over-full slide **flows onto a second page** with the same title (Typst
  reflows content); Beamer would just overflow off the slide. Keep slides
  from overfilling, or split them.
