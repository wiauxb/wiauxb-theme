#!/bin/sh
# Link this repo as the local Typst package @local/wiauxb-theme:<version>.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
version=$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$here/typst.toml")
case "$(uname -s)" in
  Darwin) data="$HOME/Library/Application Support" ;;
  *)      data="${XDG_DATA_HOME:-$HOME/.local/share}" ;;
esac
dest="${TYPST_PACKAGE_PATH:-$data/typst/packages}/local/wiauxb-theme/$version"
mkdir -p "$(dirname "$dest")"
if [ -L "$dest" ]; then rm "$dest"; elif [ -e "$dest" ]; then
  echo "error: $dest exists and is not a symlink" >&2; exit 1
fi
ln -s "$here" "$dest"
echo "installed @local/wiauxb-theme:$version -> $here"
