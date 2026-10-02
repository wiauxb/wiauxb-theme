# Changelog

All notable changes to this package. Versions follow
[semantic versioning](https://semver.org): before 1.0, a breaking change bumps
the minor version (0.1.x → 0.2.0) and anything else bumps the patch version.

Each entry says what changed for someone writing a deck. Breaking changes
start with **Breaking** and say how to update an existing deck.

## Unreleased

- `sticker`'s `width:` accepts `em` lengths (e.g. `width: 10em`), which
  failed to compile before.

## 0.1.0 — 2026-09-28

First version as a Typst package, extracted from the single-file theme
(`style/theme.typ`) used in my decks.

- Installable as `@local/wiauxb-theme:0.1.0` with `install.sh`; new decks
  with `typst init @local/wiauxb-theme:0.1.0`.
- **Breaking** (from the single-file theme): `codefile` takes the file
  content instead of a path, because a package can't read the deck's files.
  `#codefile("src/main.rs")` → `#codefile(read("src/main.rs"), name: "main.rs")`.
- **Breaking** (from the single-file theme): `sticker` takes content instead
  of a path. `#sticker("img.png", ...)` → `#sticker(image("img.png"), ...)`.
- `sticker`'s `width:` now rescales any content, not only images loaded from
  a path.
