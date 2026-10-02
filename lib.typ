// ============================================================================
//  wiauxb-theme — a Touying port of the Beamer "wiauxb" theme
//  Catppuccin colors · Roboto / JetBrainsMono · progress-bar frame titles
//  · showybox blocks · native syntax-highlighted code boxes.
//
//  Usage (see README.md / examples/showcase.typ):
//
//    #import "@local/wiauxb-theme:0.1.1": *
//    #show: wiauxb-theme.with(
//      dark: false,
//      accent: "blue",          // any Catppuccin color name, or auto
//      secondary: "maroon",
//      font: "Roboto",          // body font   (defaults: see `default-fonts`)
//      mono-font: "JetBrainsMono NFM",  // code font
//      icon-font: auto,         // Nerd Font for icons (auto = mono-font)
//      config-info(
//        title: [My talk],
//        subtitle: [A subtitle],
//        author: [Me],
//        date: datetime.today().display(),
//        logo: image("logo.png", height: 1em),
//      ),
//    )
//
//    #title-slide()
//    = A section
//    == A frame title
//    Content...
// ============================================================================

#import "@preview/touying:0.7.3": *
#import "@preview/catppuccin:1.1.0": flavors, set-code-theme
#import "@preview/showybox:2.0.4": showybox
#import "@preview/cetz:0.3.4"

// ── Fonts ───────────────────────────────────────────────────────────────────
// The ONLY place font names are written. Edit here to change them for every
// deck, or override per deck with the `font:` / `mono-font:` / `icon-font:`
// options of `wiauxb-theme`. Check available names with `typst fonts`.
//   body  — running text, titles
//   mono  — code (blocks and inline chips)
//   icons — glyphs used by blocks, accordion chevrons and timelines. Must be a
//           Nerd Font (https://www.nerdfonts.com); `auto` reuses `mono`.
#let default-fonts = (
  body: "Roboto",
  mono: "JetBrainsMono NFM",
  icons: auto,
)

// ── Palette ─────────────────────────────────────────────────────────────────
// Resolved once by `wiauxb-theme` and stashed in a state so the user-facing
// helpers (blocks, code, alert, ...) can read the active colors via `context`.
#let _pal = state("wiauxb-pal", none)

#let _resolve-palette(dark, accent, secondary, font, mono-font, icon-font) = {
  let flavor = if dark { flavors.macchiato } else { flavors.latte }
  let c = flavor.colors
  let acc = if accent == auto { if dark { "maroon" } else { "red" } } else { accent }
  let sec = if secondary == auto { if dark { "teal" } else { "green" } } else { secondary }
  (
    flavor: if dark { "macchiato" } else { "latte" },
    bg: c.base.rgb, // slidebg
    fg: c.text.rgb, // slidefg
    accent: c.at(acc).rgb,
    secondary: c.at(sec).rgb,
    ternary: c.overlay1.rgb,
    surface: c.surface0.rgb, // subtle chip background (inline code)
    // a couple of extra named colors used by the example/blocks
    red: c.red.rgb,
    green: c.green.rgb,
    // fonts travel with the palette so every helper can reach them
    font: font,
    mono: mono-font,
    icons: if icon-font == auto { mono-font } else { icon-font },
  )
}

// Run a callback with the active palette. `body => content`.
#let with-palette(f) = context f(_pal.get())

// ── Drop-shadow defaults (mirrors the Beamer theme's shadow) ─────────────────
#let _shadow(pal) = (offset: (x: 5pt, y: 5pt), color: pal.bg.darken(18%))

// ── Blocks ───────────────────────────────────────────────────────────────────
// True when a title is "empty" (no title bar should be drawn).
#let _empty(t) = t == none or t == "" or t == []

// Build the showybox `title:` argument: empty when there's no title (so no bar),
// otherwise the title with an optional right-aligned suffix (icon).
#let _title-arg(title, suffix) = if _empty(title) { (:) } else {
  (
    title: if suffix == none { title } else {
      grid(
        columns: (1fr, auto),
        title, suffix,
      )
    },
  )
}

// Subtle block: tinted body, colored border + title bar, base-colored title.
#let _block-subtle(pal, color, title, suffix, body) = showybox(
  frame: (
    title-color: color,
    border-color: color,
    body-color: pal.bg.mix((color, 5%)),
    radius: 0pt,
    thickness: 0.6pt,
  ),
  title-style: (color: pal.bg, weight: "bold"),
  body-style: (color: pal.fg),
  shadow: _shadow(pal),
  .._title-arg(title, suffix),
  body,
)

// Filled block: stronger body tint, opaque title bar.
#let _block-filled(pal, color, title, suffix, body) = showybox(
  frame: (
    title-color: color,
    border-color: color,
    body-color: pal.bg.mix((color, 25%)),
    radius: 0pt,
    thickness: 0.6pt,
  ),
  title-style: (color: pal.bg, weight: "bold"),
  body-style: (color: pal.fg),
  shadow: _shadow(pal),
  .._title-arg(title, suffix),
  body,
)

// Public block helpers (call inside slide bodies).
#let block-(title: "", color: auto, body) = with-palette(pal => _block-subtle(
  pal,
  if color == auto { pal.accent } else { color },
  title,
  none,
  body,
))
#let alert-block(title: "", body) = with-palette(pal => _block-filled(
  pal,
  pal.red,
  title,
  text(font: pal.icons)[\u{f071}],
  body, //
))
#let example-block(title: "", body) = with-palette(pal => _block-subtle(
  pal,
  pal.green,
  title,
  text(font: pal.icons)[\u{f05a}],
  body, //
))
#let theorem-block(title: "", body) = with-palette(pal => _block-subtle(
  pal,
  pal.ternary,
  title,
  none,
  body,
))

// Collapsible block driven by overlays (Beamer's accordionblock). The title bar
// is always shown with a chevron; the body is revealed only on the `reveal`
// subslides (and the chevron flips open/closed accordingly).
//   #accordion-block(title: "Details")[ always open ]
//   #accordion-block(title: "Details", reveal: "2-")[ opens on subslide 2 ]
//   #accordion-block(title: "...", color: blue, reveal: "3")[ ... ]
#let accordion-block(title: "", color: auto, reveal: none, body) = {
  let chevron-open(pal) = text(font: pal.icons)[\u{eb6e}] // ﭮ down
  let chevron-closed(pal) = text(font: pal.icons)[\u{eb70}] // ﭰ right
  if reveal == none {
    // Always open: static path (context is fine — no overlays involved).
    with-palette(pal => _block-subtle(
      pal,
      if color == auto { pal.accent } else { color },
      title,
      chevron-open(pal),
      body,
    ))
  } else {
    // Overlay-driven. showybox measures its body in a context, which hides
    // markup overlay markers — so instead we resolve visibility ourselves per
    // subslide via `touying-fn-wrapper` (gives `self`, no context needed).
    let r = if type(reveal) == int { str(reveal) } else { reveal }
    touying-fn-wrapper(
      (self: none) => {
        let pal = self.store.pal
        let open = utils.check-visible(self.subslide, r)
        _block-subtle(
          pal,
          if color == auto { pal.accent } else { color },
          title,
          if open { chevron-open(pal) } else { chevron-closed(pal) },
          if open { body } else { none },
        )
      },
      last-subslide: utils.last-required-subslide(r),
    )
  }
}

// ── Code blocks ───────────────────────────────────────────────────────────────
// Titled, shadowed box wrapping Typst's native syntax highlighting. The raw
// theme (Catppuccin tmTheme) is set globally in `init`; here we only frame it.
#let code-block(title: none, lang: none, body) = with-palette(pal => showybox(
  frame: (
    title-color: pal.ternary,
    border-color: pal.ternary,
    body-color: pal.bg.mix((pal.ternary, 5%)),
    radius: 0pt,
    thickness: 0.6pt,
  ),
  title-style: (color: pal.bg, weight: "bold"),
  // Default text color for code tokens the highlighter doesn't colorize
  // (plain identifiers, operators, punctuation). Without this, showybox
  // defaults to black → unreadable on the dark body in dark mode.
  body-style: (color: pal.fg),
  shadow: _shadow(pal),
  // Title with a right-aligned cog suffix (Beamer codeblock's nerd glyph).
  // No title + no lang → no title bar.
  .._title-arg(
    if title == none { lang } else { title },
    text(font: pal.icons)[\u{f013}],
  ),
  // `body` is expected to be a raw block (```lang ... ```).
  body,
))

// Map a file extension to a Typst raw language name (for codefile).
#let _ext-lang = (
  rs: "rust",
  py: "python",
  c: "c",
  h: "c",
  cpp: "cpp",
  cc: "cpp",
  hpp: "cpp",
  js: "javascript",
  ts: "typescript",
  typ: "typ",
  sh: "bash",
  bash: "bash",
  toml: "toml",
  json: "json",
  yaml: "yaml",
  yml: "yaml",
  html: "html",
  css: "css",
  go: "go",
  java: "java",
  rb: "ruby",
  lua: "lua",
  sql: "sql",
  md: "markdown",
  tex: "latex",
  conf: "apache",
)

// Include code from a file (Beamer's \codefile). A package cannot read the
// user's files, so the deck reads the file itself and passes its content;
// `name` (the file name or path) gives the title and, from its extension, the
// language. Either can be overridden.
//   #codefile(read("src/main.rs"), name: "src/main.rs")
//   #codefile(read("snippet.txt"), lang: "rust", title: "Example")
#let codefile(source, name: none, lang: auto, title: auto) = {
  // Catch the old path-based call `codefile("f.rs")`: a one-line source that
  // looks like a file name and no `name`.
  let looks-like-path = (
    name == none and "\n" not in source and source.split(".").last() in _ext-lang
  )
  if type(source) != str or looks-like-path {
    panic("codefile expects the file content: codefile(read(\"f.rs\"), name: \"f.rs\")")
  }
  let ext = if name == none { none } else { name.split(".").last() }
  let l = if lang != auto { lang } else if ext == none { none } else { _ext-lang.at(ext, default: none) }
  let t = if title == auto { if name == none { none } else { name.split("/").last() } } else { title }
  code-block(title: t, lang: l, raw(source, lang: l, block: true))
}

// ── Inline helpers (the "quirks", as Typst show-rule equivalents live in init) ─
#let alert(body) = with-palette(pal => text(fill: pal.accent, underline(body)))
#let strike(body) = with-palette(pal => text(fill: pal.ternary, std.strike(body)))
#let nerd(body, color: none) = with-palette(pal => {
  let c = body
  if color != none { c = text(fill: color, body) }
  text(font: pal.icons, c)
})

// Scale any content to an exact width `w`, keeping its aspect ratio.
#let fit-width(body, w) = context {
  let mw = measure(body).width
  if mw == 0pt { body } else {
    scale((w.to-absolute() / 1pt) / (mw / 1pt) * 100%, origin: left + top, reflow: true, body)
  }
}

// Scale any content (typically a logo image) to an exact height `h`, keeping
// its aspect ratio. Lets the theme bound logos per slot, so a single logo in
// `config-info` fits both the footer and the title slide regardless of the
// size it was passed at. `h` must be an absolute length (pt/cm/in).
#let fit-height(body, h) = context {
  let mh = measure(body).height
  if mh == 0pt { body } else {
    scale((h / 1pt) / (mh / 1pt) * 100%, origin: left + horizon, reflow: true, body)
  }
}

// Arrange several logos in one horizon-aligned row, for use as `logo:` in
// `config-info`. Pass sized images, e.g.
//   logo: logos(image("a.svg", height: 1em), image("b.svg", height: 1em))
// Only the images' RELATIVE sizes matter — the theme re-fits the whole row to
// each slot (small in the footer, larger on the title slide). `gap` = spacing.
#let logos(..items, gap: 0.8em) = box(grid(
  columns: (auto,) * items.pos().len(),
  column-gutter: gap,
  align: horizon,
  ..items.pos(),
))

// Framed figure: a card with a subtle outline + drop shadow (the Beamer
// theme's decorated \includegraphics). Size the image yourself, e.g.
//   #framed-image(image("plot.png", width: 80%))
//   #framed-image(image("plot.png", height: 5cm))
// Relative sizes (80%) are resolved against the available width/height: the
// card is laid out with `layout`, and the image is measured in that box.
// `fill` = card background: white (default) · none (transparent) ·
// auto (theme base) · any color. `align` positions the card (default center).
#let framed-image(body, fill: white, align: center) = layout(size => with-palette(pal => {
  let bg = if fill == none { rgb(0, 0, 0, 0) } else if fill == auto { pal.bg } else { fill }
  let card = showybox(
    frame: (
      border-color: pal.fg.transparentize(85%),
      body-color: bg,
      radius: 0pt,
      thickness: 0.5pt,
      inset: 4pt,
    ),
    shadow: _shadow(pal),
    // image width + 2× inset; `..size` lets relative image sizes resolve
    width: measure(body, ..size).width + 8pt,
    body,
  )
  if align == none { card } else { std.align(align, card) }
}))

// Sticker: an image (or any content) slapped on top of the slide, positioned
// relative to the whole PAGE and drawn above everything (title, header, footer).
// Takes no space in the flow. `width` (length, or ratio of the page width)
// rescales the content, keeping its aspect ratio.
//   #sticker(image("images/meme.png"))          // follows `#pause` like text
//   #sticker(image("images/meme.png"), at: top + right, width: 40%, reveal: "3-")
// `reveal` takes an overlay spec ("3", "2-", "2-4"). Without it, the sticker
// appears at the current `#pause` step, like any other content.
// Note: touying makes a `#pause` that follows an explicit `reveal:` continue
// after its last subslide — put stickers with `reveal:` at the end of a frame.
#let sticker(
  img,
  at: center + horizon,
  dx: 0pt,
  dy: 0pt,
  width: auto,
  angle: 0deg,
  reveal: none,
) = {
  // A path string would resolve inside this package, not the deck's folder.
  if type(img) == str {
    panic("sticker expects content, not a path: sticker(image(\"" + img + "\"))")
  }
  let spec = if reveal == none { "h-" } else if type(reveal) == int { str(reveal) } else { reveal }
  // Only emit a marker on the subslides where the sticker is visible; the page
  // foreground (`_sticker-layer`) draws every marker found on its page.
  // "h" = the current `#pause` position, resolved by touying at placement time.
  touying-fn-wrapper(
    (self: none, resolved: none) => if utils.check-visible(self.subslide, resolved) {
      [#metadata((img: img, at: at, dx: dx, dy: dy, width: width, angle: angle))<wiauxb-sticker>]
    },
    last-subslide: repetitions => {
      let r = spec.replace("h", str(repetitions))
      // "h-" must not push later pauses: it needs no subslide beyond this one.
      (utils.last-required-subslide(r), (resolved: r))
    },
  )
}

// Page foreground drawing the stickers placed on the current page.
#let _sticker-layer = context {
  let pg = here().page()
  for m in query(<wiauxb-sticker>).filter(m => m.location().page() == pg) {
    let s = m.value
    let w = if type(s.width) == ratio { page.width * s.width } else { s.width }
    let body = if w == auto { s.img } else { fit-width(s.img, w) }
    place(s.at, dx: s.dx, dy: s.dy, rotate(s.angle, reflow: true, body))
  }
}

// ── Timelines ─────────────────────────────────────────────────────────────────
// Drawn with CeTZ. `active` controls how much of the timeline is highlighted:
//   N (int)  → first N entries active
//   -1       → all active (default, matches the Beamer bare timeline)
//   auto     → advances with the subslide (one call animates across subslides)
// Tunables:
#let _tl-dot = 6      // dot radius (pt)
#let _tl-lw = 2pt       // line / outline width

#let _tl-colors(pal) = (
  active: pal.accent,
  inactive: pal.fg.transparentize(65%),
  date: pal.fg.transparentize(45%),
  bg: pal.bg,
  fg: pal.fg,
)

// Resolve `active` to a concrete count in [0, n].
#let _tl-resolve(active, n, subslide) = {
  if active == auto { calc.min(subslide, n) } else if active == -1 { n } else { calc.max(0, calc.min(active, n)) }
}

// Draw a dot at (x, y): filled when active, hollow (bg fill + outline) otherwise.
#let _tl-dot-at(draw, x, y, is-active, c) = {
  if is-active {
    draw.circle((x, y), radius: _tl-dot, fill: c.active, stroke: none)
  } else {
    draw.circle((x, y), radius: _tl-dot, fill: c.bg, stroke: _tl-lw + c.inactive)
  }
}

// ── Horizontal, discrete ────────────────────────────────────────────────────
#let _htl-discrete(labels, active, pal) = {
  let n = labels.len()
  let c = _tl-colors(pal)
  layout(size => cetz.canvas(length: 1pt, {
    import cetz.draw as draw
    import cetz.draw: *
    let pad = 10
    let w = size.width / 1pt
    let usable = w - 2 * pad
    let xof(i) = if n > 1 { pad + i * usable / (n - 1) } else { pad + usable / 2 }
    line((pad, 0), (w - pad, 0), stroke: _tl-lw + c.inactive)
    if active > 0 {
      line((pad, 0), (xof(active - 1), 0), stroke: _tl-lw + c.active)
    }
    for (i, lbl) in labels.enumerate() {
      let x = xof(i)
      _tl-dot-at(draw, x, 0, (i + 1) <= active, c)
      content((x, -_tl-dot - 4), anchor: "north", text(size: 0.8em, fill: c.fg, lbl))
    }
  }))
}

#let htimeline(items, active: -1) = {
  if active == auto {
    touying-fn-wrapper(
      (self: none) => _htl-discrete(items, _tl-resolve(auto, items.len(), self.subslide), self.store.pal),
      last-subslide: items.len(),
    )
  } else {
    with-palette(pal => _htl-discrete(items, _tl-resolve(active, items.len(), 0), pal))
  }
}

// ── Horizontal, date axis ────────────────────────────────────────────────────
// Entries: each is a year, or a (year, label) pair. Positioned on a from..to
// axis with tick marks every `tick` years; dates below dots, labels above
// (only when the label differs from the year).
#let _htl-dates(entries, from, to, tick, active, pal) = {
  let c = _tl-colors(pal)
  let es = entries.map(e => if type(e) == array { (e.at(0), e.at(1)) } else { (e, e) })
  layout(size => cetz.canvas(length: 1pt, {
    import cetz.draw as draw
    import cetz.draw: *
    let pad = 10
    let w = size.width / 1pt
    let usable = w - 2 * pad
    let range = to - from
    let xof(yr) = pad + (yr - from) * usable / range
    line((pad, 0), (w - pad, 0), stroke: _tl-lw + c.inactive)
    // tick marks
    let t = from
    while t <= to {
      line((xof(t), -6), (xof(t), 6), stroke: _tl-lw + c.inactive)
      t += tick
    }
    // active segment: first entry → active entry (by year)
    if active > 0 {
      line((xof(es.first().at(0)), 0), (xof(es.at(active - 1).at(0)), 0), stroke: _tl-lw + c.active)
    }
    // Pre-measure the above-axis labels and greedily stack overlapping ones onto
    // higher rows so close-together years (e.g. 2007/2008) don't print on top of
    // each other. `row` 0 sits just above the axis; each extra row lifts a label
    // by one line height. The connector line keeps lifted labels readable.
    let lbl-gap = 6 // min horizontal pt between labels in a row
    let bodies = es.map(((yr, lbl)) => text(size: 0.8em, fill: c.fg, lbl))
    let lh = (
      es
        .enumerate()
        .fold(0pt, (m, p) => {
          let (i, _) = p
          calc.max(m, measure(bodies.at(i)).height)
        })
        / 1pt
        + 4
    )
    let row-right = () // right edge (pt) currently used per row
    for (i, (yr, lbl)) in es.enumerate() {
      let x = xof(yr)
      _tl-dot-at(draw, x, 0, (i + 1) <= active, c)
      content((x, -_tl-dot - 6), anchor: "north", text(size: 0.7em, fill: c.date, str(yr)))
      if str(lbl) != str(yr) {
        let half = measure(bodies.at(i)).width / 1pt / 2
        let left = x - half
        // lowest row whose last label clears this one's left edge
        let row = 0
        while row < row-right.len() and row-right.at(row) + lbl-gap > left { row += 1 }
        if row == row-right.len() { row-right.push(x + half) } else { row-right.at(row) = x + half }
        let y = _tl-dot + 6 + row * lh
        // connector from the dot up to a lifted label
        if row > 0 {
          line((x, _tl-dot), (x, y), stroke: 0.5pt + c.inactive)
        }
        content((x, y), anchor: "south", bodies.at(i))
      }
    }
  }))
}

#let htimeline-dates(entries, from: none, to: none, tick: 1, active: -1) = {
  assert(from != none and to != none, message: "htimeline-dates needs from: and to:")
  if active == auto {
    touying-fn-wrapper(
      (self: none) => _htl-dates(
        entries,
        from,
        to,
        tick,
        _tl-resolve(auto, entries.len(), self.subslide),
        self.store.pal,
      ),
      last-subslide: entries.len(),
    )
  } else {
    with-palette(pal => _htl-dates(entries, from, to, tick, _tl-resolve(active, entries.len(), 0), pal))
  }
}

// ── Vertical ─────────────────────────────────────────────────────────────────
// Entries are dicts: (title: [..], desc: [..] (optional), icon: "\u{..}" (opt)).
// Spacing adapts to each entry's measured height so descriptions don't overlap.
#let _vtl(entries, active, pal) = {
  let c = _tl-colors(pal)
  let n = entries.len()
  layout(size => {
    let em = 1em.to-absolute()
    let line-x = 0.8 * em / 1pt
    let text-x = 2.0 * em / 1pt
    let textw = size.width - 2.8 * em
    let gap = 0.9 * em / 1pt
    // Build + measure each text block.
    let blocks = entries.map(e => box(width: textw, {
      strong(text(fill: c.active, e.at("title", default: "")))
      let desc = e.at("desc", default: none)
      if desc != none and desc != [] {
        linebreak()
        text(size: 0.8em, fill: c.fg.transparentize(20%), desc)
      }
    }))
    let heights = blocks.map(b => measure(b).height / 1pt)
    // Top y of each block (y grows downward = negative).
    let tops = ()
    let y = 0
    for h in heights {
      tops.push(y)
      y -= (h + gap)
    }
    let doty(i) = tops.at(i) - 0.55 * em / 1pt // center dot on the title line
    cetz.canvas(length: 1pt, {
      import cetz.draw as draw
      import cetz.draw: *
      line((line-x, doty(0)), (line-x, doty(n - 1)), stroke: _tl-lw + c.inactive)
      if active > 1 {
        line((line-x, doty(0)), (line-x, doty(calc.min(active, n) - 1)), stroke: _tl-lw + c.active)
      }
      for (i, e) in entries.enumerate() {
        let is-act = (i + 1) <= active
        let icon = e.at("icon", default: none)
        if icon == none {
          _tl-dot-at(draw, line-x, doty(i), is-act, c)
        } else {
          content((line-x, doty(i)), text(
            font: pal.icons,
            size: 1.1em,
            fill: if is-act { c.active } else { c.inactive },
            icon,
          ))
        }
        content((text-x, tops.at(i)), anchor: "north-west", blocks.at(i))
      }
    })
  })
}

#let vtimeline(..entries-and-opts) = {
  let entries = entries-and-opts.pos()
  let active = entries-and-opts.named().at("active", default: -1)
  if active == auto {
    touying-fn-wrapper(
      (self: none) => _vtl(entries, _tl-resolve(auto, entries.len(), self.subslide), self.store.pal),
      last-subslide: entries.len(),
    )
  } else {
    with-palette(pal => _vtl(entries, _tl-resolve(active, entries.len(), 0), pal))
  }
}

// ── Frame-title subtitle ───────────────────────────────────────────────────────
// Place `#subtitle[...]` anywhere in a frame body. It renders nothing inline;
// instead the slide header picks it up and shows it to the right of the frame
// title, separated by an em dash (Beamer's "Title --- Subtitle").
#let subtitle(body) = [#metadata(body)<wiauxb-subtitle>]

// Find the subtitle declared on the current page (if any).
#let _subtitle-here() = {
  let cur = here().page()
  let hit = none
  for m in query(<wiauxb-subtitle>) {
    if m.location().page() == cur {
      hit = m.value
      break
    }
  }
  hit
}

// ── Slide function (header = title+progress+number, footer = logo+section) ─────
#let slide(config: (:), repeat: auto, setting: body => body, composer: auto, ..bodies) = touying-slide-wrapper(self => {
  let pal = self.store.pal

  let header(self) = {
    // Title row: frame title (current level-2 heading), optional subtitle to
    // its right separated by an em dash, and the frame number far right.
    let title-block = context {
      let sub = _subtitle-here()
      text(weight: "bold", size: 1.1em, fill: pal.fg, utils.display-current-heading(level: 2, style: auto))
      if sub != none {
        text(size: 0.85em, fill: pal.ternary)[ #sym.space #sym.dash.em #sym.space #sub]
      }
    }
    grid(
      columns: (1fr, auto),
      align: (bottom, bottom + right),
      title-block, text(size: 0.7em, fill: pal.ternary, context utils.slide-counter.display()),
    )
    v(-0.55em)
    // Progress bar: filled fraction = current / total.
    utils.touying-progress(ratio => box(width: 100%, {
      place(left, rect(width: 100%, height: 1.2pt, fill: pal.fg.transparentize(92%), stroke: none))
      place(left, rect(width: ratio * 100%, height: 1.2pt, fill: pal.accent, stroke: none))
    }))
  }

  let footer(self) = text(size: 0.6em, fill: pal.ternary, {
    grid(
      columns: (1fr, 1fr),
      align: (left + horizon, right + horizon),
      // Fit the logo to the footer height so any logo stays in bounds.
      if self.info.logo != none { fit-height(self.info.logo, 0.8cm) },
      {
        self.info.title
        context {
          // style: auto shrinks level-1 headings to .715em; pass an explicit
          // style returning just the body so the section matches the title size.
          let sec = utils.display-current-heading(level: 1, style: ch => ch.body)
          if sec != none [ --- #sec]
        }
      },
    )
  })

  let self = utils.merge-dicts(
    self,
    // Bigger top margin only for content slides → more space above the frame
    // title. The title-slide / focus-slide set their own margin, so they are
    // unaffected. Tune `top` here for the space above the slide title.
    config-page(header: header, footer: footer, margin: (top: 3.6em, bottom: 2em, x: 2em)),
  )
  // Optional vertical centering of the body (theme option `center-body`).
  let setting = if self.store.at("center-body", default: false) {
    body => align(horizon, setting(body))
  } else { setting }
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

// ── Title slide (mirrors the Beamer title page) ────────────────────────────────
// An optional body is drawn on top, e.g. stickers:
//   #title-slide[#sticker("images/meme.png", at: center + horizon)]
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  let extra = args.pos().join()
  let pal = self.store.pal
  let info = self.info
  let self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(header: none, footer: none))
  // Vertically centered (robust, single page). The page top/bottom margins
  // provide the breathing room above/below.
  let body = align(center + horizon, {
    line(length: 60%, stroke: 0.6pt + pal.accent)
    v(0.6em)
    text(size: 1.6em, weight: "bold", fill: pal.fg, info.title)
    if info.subtitle != none {
      v(0.3em)
      text(size: 1.0em, fill: pal.ternary, info.subtitle)
    }
    v(0.6em)
    line(length: 60%, stroke: 0.6pt + pal.accent)
    v(2em)
    text(fill: pal.ternary, {
      info.author
      if info.date != none [ --- #info.date]
    })
    if info.logo != none {
      v(2em)
      // Bound the title-slide logo so it can't overflow the page.
      fit-height(info.logo, 1.2cm)
    }
  })
  touying-slide(self: self, config: config, {
    extra
    body
  })
})

// ── Centered big-title slide (Beamer's empty-body frame) ───────────────────────
// Optional `subtitle:` shows a smaller line below the big title.
//   #focus-slide(subtitle: [a subtitle])[Behold!]
// Set `invert: true` to flip the colors: accent background with base-colored
// text, instead of the default base background with accent-colored text.
//   #focus-slide(invert: true)[Behold!]
#let focus-slide(config: (:), subtitle: none, invert: false, body) = touying-slide-wrapper(self => {
  let pal = self.store.pal
  // Foreground = the color the title/subtitle are painted in; the page fill is
  // its complement. Normal: accent text on the base bg. Inverted: base-colored
  // text on an accent bg.
  let fg = if invert { pal.bg } else { pal.accent }
  let bg = if invert { pal.accent } else { pal.bg }
  let self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(
    header: none,
    footer: none,
    fill: bg,
  ))
  touying-slide(self: self, config: config, align(center + horizon, {
    text(fill: fg, size: 2em, weight: "bold", body)
    if subtitle != none {
      v(-1em)
      text(fill: fg.transparentize(20%), size: 1em, weight: "regular", subtitle)
    }
  }))
})

// ── The theme entry point ──────────────────────────────────────────────────────
#let wiauxb-theme(
  dark: false,
  accent: auto,
  secondary: auto,
  aspect-ratio: "16-9",
  center-body: true, // vertically center the body of content slides
  font: default-fonts.body, // body font
  mono-font: default-fonts.mono, // code font
  icon-font: default-fonts.icons, // Nerd Font for icons; auto = mono-font
  ..args,
  body,
) = {
  let pal = _resolve-palette(dark, accent, secondary, font, mono-font, icon-font)

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      fill: pal.bg,
      margin: (top: 2.4em, bottom: 2em, x: 2em),
      foreground: _sticker-layer, // draws `#sticker`s above everything
    ),
    config-common(
      slide-fn: slide,
      // No section divider slides: a `= Section` only registers the heading
      // (for the outline + footer), it does not produce a slide of its own.
      new-section-slide-fn: none,
      zero-margin-header: false,
      zero-margin-footer: false,
    ),
    config-methods(
      init: (self: none, body) => {
        // Fonts
        set text(font: pal.font, size: 22pt, fill: pal.fg)
        show raw: set text(font: pal.mono)
        // Code highlighting follows the active flavor. Uses the catppuccin
        // package's bundled tmTheme (resolved package-relative, so it works
        // wherever this directory is moved — no local asset needed).
        show: set-code-theme.with(if dark { flavors.macchiato } else { flavors.latte })
        // Wrap long code lines (Beamer breaklines/breakanywhere): code boxes
        // bound the width so lines break at spaces; the zero-width spaces below
        // add break points inside long unbroken tokens too.
        show raw.where(block: true): it => {
          show regex("."): c => c + "\u{200B}"
          it
        }

        // Lists: accent markers.
        set list(marker: (text(fill: pal.accent)[•], text(fill: pal.accent)[--], text(fill: pal.accent)[·]))
        set enum(numbering: n => text(fill: pal.accent)[#n.])

        // ── The "quirks": Beamer recolored standard commands. ──
        // *bold*  -> accent          (Beamer \textbf / \emph)
        show strong: set text(fill: pal.accent)
        // _italic_ -> accent italic  (Beamer \emph)
        show emph: set text(fill: pal.accent)
        // `inline code` -> a subtle "chip": tinted background, neutral text.
        // Syntax-highlighted when a lang is given (`` `rust fn f()` ``), since
        // set-code-theme above applies to inline raw too.
        show raw.where(block: false): it => box(
          fill: pal.surface,
          inset: (x: 0.35em),
          outset: (y: 0.32em),
          radius: 0.25em,
          it,
        )

        // Block quote (Beamer's restyled quote): left bar, italic body, and an
        // optional right-aligned attribution. Use:
        //   #quote(block: true, attribution: [Author])[ ... ]
        show quote.where(block: true): it => block(
          width: 100%,
          inset: (left: 1.2em, top: 0.2em, bottom: 0.2em),
          stroke: (left: 2.5pt + pal.fg.transparentize(15%)),
          {
            set text(style: "italic", fill: pal.fg.transparentize(15%))
            it.body
            if it.attribution != none {
              set text(style: "normal", fill: pal.ternary)
              align(right, [— #it.attribution])
            }
          },
        )

        // Publish the palette for body-level helpers.
        _pal.update(pal)
        body
      },
    ),
    config-store(pal: pal, center-body: center-body),
    config-colors(
      primary: pal.accent,
      secondary: pal.secondary,
      neutral-lightest: pal.bg,
      neutral-darkest: pal.fg,
    ),
    ..args,
  )

  body
}
