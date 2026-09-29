# Contributing

Changes go through merge requests on the git repo. This file covers how to
test a change, which version number it needs, and how to release it.

## How versions work

Typst imports pin an exact version: `@local/wiauxb-theme:0.1.0` always means
0.1.0, with no version ranges and no automatic upgrades. Each version is a
folder in Typst's local package directory, and `install.sh` fills those
folders from the git tags (`v0.1.0` → `…/local/wiauxb-theme/0.1.0/`).

So **a released version must never change**. Old decks import it and expect
to compile exactly as they did. Every fix, however small, ships as a new
version.

## Test a change

1. If `main` doesn't already carry an unreleased version, bump it to the
   version your change will ship in (see [below](#which-version)). The
   version is written in `typst.toml` and in the import line of
   `template/main.typ`, `examples/showcase.typ` and `README.md`; change them
   all, then check nothing still has the old one:

   ```sh
   grep -rn "wiauxb-theme:" --include=*.typ --include=*.md .
   ```

   (`CHANGELOG.md` and this file mention old versions on purpose.)
2. Link your working copy under that version:

   ```sh
   ./install.sh --dev
   ```

   It refuses to link over a released version, so a dev install can't
   silently change what old decks compile against.
3. Check the showcase, which uses every feature, in both `dark: false` and
   `dark: true`, and any deck of yours that the change touches:

   ```sh
   typst compile examples/showcase.typ
   ```
4. Add a line under `## Unreleased` in `CHANGELOG.md`.

## Which version

Before 1.0, `0.MINOR.PATCH`:

| Change | Bump | Example |
|---|---|---|
| Breaking: a deck that compiled before errors, or looks different in a way its author would notice (renamed/removed option, changed signature, different default) | minor: `0.1.3 → 0.2.0` | `codefile` taking content instead of a path |
| New function or option, old decks unchanged | minor: `0.1.3 → 0.1.4` | a new `quote-block` |
| Bug fix, small visual correction | patch: `0.1.3 → 0.1.4` | wrong text color in dark mode |

Several changes can go into the same unreleased version; use the biggest
bump any of them needs.

We will bump to 1.0.0 once the theme is well matured and tested enough.

## Release

From an up-to-date `main`, with the version you're releasing (say `0.2.0`)
already in `typst.toml`:

1. **Version.** Re-run the `grep` from [Test a change](#test-a-change):
   every import must name the new version.
2. **Changelog.** Rename `## Unreleased` to `## 0.2.0 — YYYY-MM-DD` and add
   a new empty `## Unreleased` above it. Mark breaking changes with
   **Breaking** and say how to update a deck.
3. **Check.** `typst compile examples/showcase.typ` and
   `typst init @local/wiauxb-theme:0.2.0 /tmp/t && typst compile /tmp/t/main.typ`
   (run `./install.sh --dev` first so the version exists).
4. **Commit and tag.**

   ```sh
   git commit -am "Release 0.2.0"
   git tag -a v0.2.0 -m "0.2.0"
   git push && git push --tags
   ```

   The tag must be `v` + the version in `typst.toml`; `install.sh` checks.
5. **Install the release.** `./install.sh 0.2.0` replaces your dev link with
   a frozen copy of the tag.
6. **Optional:** create a release on GitLab/GitHub from the tag and paste the
   changelog entry, and tell co-workers to `git pull && ./install.sh`.

Never move or delete a pushed tag. If a release is broken, fix it in a new
patch version.

## Fixing an old version

Decks pinned to an old version keep it; that's the point. If an old deck
needs a fix, update its import to the latest version (the changelog lists
what to change). Only if that's impractical, release a patch from the old
tag:

```sh
git switch -c release-0.1 v0.1.0     # branch from the old release
# fix, set version = "0.1.1", changelog entry
git commit -am "Release 0.1.1" && git tag -a v0.1.1 -m "0.1.1"
git push -u origin release-0.1 && git push --tags
```

and add the fix to `main` too if it applies there.

## Style

- Match the surrounding code: comment density, naming (`_private` helpers,
  kebab-case), 2-space indents.
- Every user-facing function gets a comment with a usage example, and a
  mention in `README.md`.
- Colors come from the palette (`with-palette`, `self.store.pal`), fonts from
  `pal.font` / `pal.mono` / `pal.icons`; never hard-code them.
- Anything that reads a file takes content (`read(...)`, `image(...)`), not a
  path: a path would resolve inside the package, not the deck.
