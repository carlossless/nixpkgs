#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git common-updater-scripts
set -euo pipefail

attr="q2pro"

tmpdir=$(mktemp -d "/tmp/$attr.XXX")
repo="$tmpdir/repo"
trap 'rm -rf $tmpdir' EXIT

git clone https://github.com/skullernet/q2pro.git "$repo"

rev="$(git -C "$repo" rev-parse HEAD)"
revCount="$(git -C "$repo" rev-list --count HEAD)"
sourceDate="$(git -C "$repo" show -s --format=%ct HEAD)"
version="$revCount"

echo "Updating $attr to version $version (rev: $rev, date: $sourceDate)"

update-source-version "$attr" "$version" --rev="$rev" --source-date-epoch="$sourceDate"
