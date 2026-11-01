#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION=v0.3.0
REPO="${ATLAS_REPO:-cevherdogan/native-nations-atlas}"
DEST="${ATLAS_DEST:-$HOME/github/native-nations-atlas}"
for c in git gh python3; do command -v "$c" >/dev/null || { echo "Missing $c"; exit 1; }; done
gh auth status >/dev/null || { echo 'Authenticate gh first'; exit 1; }
python3 "$ROOT/tests/validate_v030.py" "$ROOT"
[[ -d "$DEST/.git" ]] || { echo "Expected existing repository at $DEST; refusing to initialize over unknown state"; exit 1; }
[[ -z "$(git -C "$DEST" status --porcelain)" ]] || { echo 'Dirty working tree: abort'; exit 1; }
git -C "$DEST" fetch origin --tags
[[ "$(git -C "$DEST" branch --show-current)" == main ]] || { echo 'Expected main branch'; exit 1; }
[[ "$(git -C "$DEST" rev-parse HEAD)" == "$(git -C "$DEST" rev-parse origin/main)" ]] || { echo 'Local/remote divergence: abort'; exit 1; }
if git -C "$DEST" rev-parse -q --verify "refs/tags/$VERSION" >/dev/null || gh release view "$VERSION" -R "$REPO" >/dev/null 2>&1; then echo 'Release already exists; abort'; exit 1; fi
# Preflight every conflicting file against exact previous release baseline.
while IFS= read -r -d '' f; do
 rel="${f#"$ROOT"/}"
 if [[ -f "$DEST/$rel" ]] && ! cmp -s "$f" "$DEST/$rel"; then
   if [[ ! -f "$ROOT/legacy/v0.2.1/$rel" ]] || ! cmp -s "$DEST/$rel" "$ROOT/legacy/v0.2.1/$rel"; then
     echo "Collision: $rel (not matching v0.2.1 baseline); abort"; exit 1
   fi
 fi
done < <(find "$ROOT" -type f -print0)
backup="$DEST/.atlas-backup-$VERSION-$(date +%Y%m%d%H%M%S)"
mkdir -p "$backup"
while IFS= read -r -d '' f; do
 rel="${f#"$ROOT"/}"
 if [[ -f "$DEST/$rel" ]] && ! cmp -s "$f" "$DEST/$rel"; then mkdir -p "$backup/$(dirname "$rel")"; cp "$DEST/$rel" "$backup/$rel"; fi
 mkdir -p "$DEST/$(dirname "$rel")"; cp "$f" "$DEST/$rel"
done < <(find "$ROOT" -type f -print0)
python3 "$DEST/tests/validate_v030.py" "$DEST"
git -C "$DEST" add README.md app data docs tests legacy bin
if git -C "$DEST" diff --cached --quiet; then echo 'No changes to release'; exit 1; fi
git -C "$DEST" commit -m "release: Native Nations Atlas $VERSION"
git -C "$DEST" tag -a "$VERSION" -m "Native Nations Atlas $VERSION"
git -C "$DEST" push origin main
git -C "$DEST" push origin "$VERSION"
zip="$ROOT/../native-nations-atlas-v0.3.0.zip"
if [[ -f "$zip" ]]; then gh release create "$VERSION" "$zip" -R "$REPO" --title "Native Nations Atlas $VERSION" --notes-file "$ROOT/docs/CHANGELOG.md"; else gh release create "$VERSION" -R "$REPO" --title "Native Nations Atlas $VERSION" --notes-file "$ROOT/docs/CHANGELOG.md"; fi
gh release view "$VERSION" -R "$REPO" --json url,tagName
[[ -n "$(git -C "$DEST" ls-remote --tags origin "refs/tags/$VERSION")" ]]
echo "Verified $REPO $VERSION"
