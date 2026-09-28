#!/bin/sh
# Install wiauxb-theme as the local Typst package @local/wiauxb-theme:<version>.
#
#   ./install.sh              install the latest released version (newest tag)
#   ./install.sh 0.1.1        install release 0.1.1 (tag v0.1.1)
#   ./install.sh --all        install every released version
#   ./install.sh --dev        link this working copy under the version in
#                             typst.toml, to test unreleased changes
#
# Releases are frozen copies of their git tag, so decks pinned to a version
# always compile the same. A dev install is a symlink: edits show up on the
# next compile. Add --force to replace an already installed release.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
name=wiauxb-theme

case "$(uname -s)" in
  Darwin) data="$HOME/Library/Application Support" ;;
  *)      data="${XDG_DATA_HOME:-$HOME/.local/share}" ;;
esac
root="${TYPST_PACKAGE_PATH:-$data/typst/packages}/local/$name"

die() { echo "error: $*" >&2; exit 1; }

# Version declared in a typst.toml read from stdin.
manifest_version() { sed -n 's/^version *= *"\(.*\)"/\1/p'; }

# Released versions, oldest first (tags vX.Y.Z).
releases() { git -C "$here" tag --list 'v[0-9]*' --sort=v:refname | sed 's/^v//'; }

install_release() {
  version=$1
  tag="v$version"
  dest="$root/$version"
  git -C "$here" rev-parse -q --verify "refs/tags/$tag" >/dev/null \
    || die "no tag $tag (released: $(releases | tr '\n' ' '))"
  tagged=$(git -C "$here" show "$tag:typst.toml" | manifest_version)
  [ "$tagged" = "$version" ] \
    || die "tag $tag has version \"$tagged\" in typst.toml, expected \"$version\""

  if [ -L "$dest" ]; then
    rm "$dest" # a dev link for this version: the release supersedes it
  elif [ -e "$dest" ]; then
    if [ "$force" = 1 ]; then
      rm -rf "$dest"
    else
      echo "@local/$name:$version already installed (use --force to reinstall)"
      return
    fi
  fi
  mkdir -p "$dest"
  git -C "$here" archive "$tag" | tar -x -C "$dest"
  echo "installed @local/$name:$version (frozen copy of $tag)"
}

install_dev() {
  version=$(manifest_version <"$here/typst.toml")
  dest="$root/$version"
  if git -C "$here" rev-parse -q --verify "refs/tags/v$version" >/dev/null; then
    die "$version is already released; bump version in typst.toml before a dev install"
  fi
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    die "$dest exists and is not a dev link"
  fi
  mkdir -p "$root"
  ln -s "$here" "$dest"
  echo "linked @local/$name:$version -> $here (dev)"
}

git -C "$here" rev-parse --git-dir >/dev/null 2>&1 \
  || die "$here is not a git clone"

force=0
mode=latest
version=
for arg in "$@"; do
  case "$arg" in
    --force) force=1 ;;
    --dev) mode=dev ;;
    --all) mode=all ;;
    -h|--help) sed -n '2,12s/^# \{0,1\}//p' "$0"; exit 0 ;;
    -*) die "unknown option $arg" ;;
    *) mode=one; version=${arg#v} ;;
  esac
done

case "$mode" in
  dev) install_dev ;;
  one) install_release "$version" ;;
  all)
    [ -n "$(releases)" ] || die "no released version (no vX.Y.Z tag)"
    for v in $(releases); do install_release "$v"; done
    ;;
  latest)
    latest=$(releases | tail -n 1)
    [ -n "$latest" ] || die "no released version yet; use --dev"
    install_release "$latest"
    ;;
esac
