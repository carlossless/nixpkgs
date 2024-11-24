#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git common-updater-scripts
set -euo pipefail

attr="q2pro"

pkgDir=$(dirname "${BASH_SOURCE[@]}")
nixFile="$pkgDir/package.nix"
nixpkgsRoot=$(cd "$pkgDir" && git rev-parse --show-toplevel)

tmpdir=$(mktemp -d "/tmp/$attr.XXX")
repo="$tmpdir/repo"
trap 'rm -rf $tmpdir' EXIT

git clone https://github.com/skullernet/q2pro.git "$repo"

rev="$(git -C "$repo" rev-parse HEAD)"
revCount="$(git -C "$repo" rev-list --count HEAD)"
sourceDate="$(git -C "$repo" show -s --format=%ct HEAD)"
version="$revCount"

echo "Updating q2pro to version $version (rev: $rev, date: $sourceDate)"

update-source-version "$attr" "$version" --rev="${rev}" --file="${nixFile}"

oldSourceDate=$(nix eval -f "$nixpkgsRoot/default.nix" "$attr.SOURCE_DATE_EPOCH")
if [ "$oldSourceDate" != "$sourceDate" ]; then
    sed -i -re "/\bSOURCE_DATE_EPOCH\b\s*=/ s|$oldSourceDate|$sourceDate|" "$nixFile"
else
    echo "SOURCE_DATE_EPOCH is already up to date"
fi
