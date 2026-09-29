// =============================================================================
//  New deck — created with `typst init @local/wiauxb-theme:0.1.1`.
//  Build:  typst watch main.typ   (or  typst compile main.typ)
// =============================================================================
#import "@local/wiauxb-theme:0.1.1": *

#show: wiauxb-theme.with(
  // dark: true,                  // Macchiato instead of Latte
  // accent: "blue",              // any Catppuccin name, or omit for auto
  // secondary: "maroon",
  config-info(
    title: [Talk title],
    subtitle: [Optional subtitle],
    author: [Your name],
    date: datetime.today().display(),
    // logo: logos(
    //   image("images/logo-a.svg", height: 1em),
    //   image("images/logo-b.svg", height: 1em),
    // ),
  ),
)

// ── Title ────────────────────────────────────────────────────────────────────
#title-slide()

// ── Optional: outline. Remove if you don't want it. ──────────────────────────
== Outline
// Sections only (Beamer-style). Drop `target:` to also list every frame.
#components.adaptive-columns(outline(title: none, target: heading.where(level: 1), indent: 1em))


= First section

== A frame
#subtitle[optional subtitle]

content
