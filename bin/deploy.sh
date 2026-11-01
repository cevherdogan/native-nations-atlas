#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${ATLAS_DEST:-$HOME/github/native-nations-atlas}"
REPO="${ATLAS_REPO:-cevherdogan/native-nations-atlas}"
VERSION=v0.3.4
for cmd in git gh python3; do command -v "$cmd" >/dev/null || { echo "Missing $cmd"; exit 1; }; done
python3 "$ROOT/tests/validate_v034.py" "$ROOT"
[[ -d "$DEST/.git" ]] || { echo "Repository missing: $DEST"; exit 1; }
EXCLUDE="$(git -C "$DEST" rev-parse --git-path info/exclude)"
[[ "$EXCLUDE" = /* ]] || EXCLUDE="$DEST/$EXCLUDE"
mkdir -p "$(dirname "$EXCLUDE")"
grep -qxF '.atlas-backup-*/' "$EXCLUDE" 2>/dev/null || printf '\n.atlas-backup-*/\n' >> "$EXCLUDE"
[[ -z "$(git -C "$DEST" status --porcelain)" ]] || { git -C "$DEST" status --short; echo 'Uncommitted changes; abort'; exit 1; }
[[ "$(git -C "$DEST" branch --show-current)" == main ]] || { echo 'Expected main branch'; exit 1; }
gh auth status >/dev/null
git -C "$DEST" fetch origin --tags
[[ "$(git -C "$DEST" rev-parse HEAD)" == "$(git -C "$DEST" rev-parse origin/main)" ]] || { echo 'Remote diverged'; exit 1; }
current="$(git -C "$DEST" describe --tags --exact-match HEAD 2>/dev/null || true)"
if [[ "$current" == "$VERSION" ]]; then echo 'Already installed'; gh release view "$VERSION" -R "$REPO" --json url,tagName; exit 0; fi
[[ "$current" == v0.3.3 ]] || { echo "Requires v0.3.3, found ${current:-untagged}"; exit 1; }
! git -C "$DEST" rev-parse -q --verify "refs/tags/$VERSION" >/dev/null || { echo 'Tag exists'; exit 1; }
python3 - "$ROOT" "$DEST" <<'PYCODE'
from pathlib import Path
import json,hashlib,sys
src,dst=map(Path,sys.argv[1:]); baseline=json.loads((src/'data/upgrade_baseline_v033.json').read_text())
for rel,digest in baseline.items():
 p=dst/rel
 if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest()!=digest: raise SystemExit('Modified baseline: '+rel)
for rel in ['auth/README.md','auth/config.example.php','app/aa-preview.html','tests/validate_v034.py','data/upgrade_baseline_v033.json']:
 if (dst/rel).exists():raise SystemExit('New-file collision: '+rel)
print('Baseline verified')
PYCODE
BACKUP="$HOME/Downloads/native-nations-atlas-backups/$VERSION-$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP"
python3 - "$ROOT" "$DEST" "$BACKUP" <<'PYCODE'
from pathlib import Path
import sys,shutil
src,dst,backup=map(Path,sys.argv[1:]); rels=['README.md','docs/CHANGELOG.md','auth/README.md','auth/config.example.php','app/aa-preview.html','tests/validate_v034.py','data/upgrade_baseline_v033.json','bin/deploy.sh']
for rel in rels:
 old=dst/rel;new=src/rel
 if old.exists():
  target=backup/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(old,target)
 old.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(new,old)
print('External backup:',backup)
PYCODE
python3 "$DEST/tests/validate_v034.py" "$DEST"
git -C "$DEST" add README.md docs/CHANGELOG.md auth/README.md auth/config.example.php app/aa-preview.html tests/validate_v034.py data/upgrade_baseline_v033.json bin/deploy.sh
git -C "$DEST" commit -m "release: Native Nations Atlas $VERSION AA contract"
git -C "$DEST" tag -a "$VERSION" -m "Native Nations Atlas $VERSION"
git -C "$DEST" push origin main
git -C "$DEST" push origin "$VERSION"
ZIP="$ROOT/../native-nations-atlas-v0.3.4.zip"
if [[ -f "$ZIP" ]]; then gh release create "$VERSION" "$ZIP" -R "$REPO" --title "Native Nations Atlas $VERSION" --notes-file "$ROOT/docs/CHANGELOG.md"; else gh release create "$VERSION" -R "$REPO" --title "Native Nations Atlas $VERSION" --notes-file "$ROOT/docs/CHANGELOG.md"; fi
gh release view "$VERSION" -R "$REPO" --json url,tagName
[[ -n "$(git -C "$DEST" ls-remote --tags origin "refs/tags/$VERSION")" ]]
[[ -z "$(git -C "$DEST" status --porcelain)" ]] || { echo 'Post-release dirty tree'; exit 1; }
echo 'Release verified. AA remains inactive pending verified bridge integration.'
