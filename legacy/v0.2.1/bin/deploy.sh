#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION=v0.2.1
REPO="${ATLAS_REPO:-cevherdogan/native-nations-atlas}"
DEST="${ATLAS_DEST:-$HOME/github/native-nations-atlas}"
VISIBILITY="${ATLAS_VISIBILITY:-public}"
command -v git >/dev/null || { echo 'Install git'; exit 1; }
command -v gh >/dev/null || { echo 'Install GitHub CLI (gh)'; exit 1; }
gh auth status >/dev/null || { echo 'Authenticate: gh auth login'; exit 1; }
python3 "$ROOT/tests/validate_v021.py" "$ROOT"
if [[ -e "$DEST" && ! -d "$DEST/.git" ]]; then echo "Refusing non-git destination: $DEST"; exit 1; fi
if [[ -d "$DEST/.git" ]]; then
  [[ -z "$(git -C "$DEST" status --porcelain)" ]] || { echo 'Refusing dirty checkout'; exit 1; }
  git -C "$DEST" fetch --tags origin
  [[ "$(git -C "$DEST" rev-list --count HEAD..origin/main 2>/dev/null || echo 0)" == 0 ]] || { echo 'Remote ahead: pull/reconcile first'; exit 1; }
else
  mkdir -p "$(dirname "$DEST")"
  if gh repo view "$REPO" >/dev/null 2>&1; then gh repo clone "$REPO" "$DEST"; else
    mkdir -p "$DEST"; git -C "$DEST" init -b main
    gh repo create "$REPO" "--$VISIBILITY" --description 'Native Nations Atlas: living Indigenous nations, cultures and homelands' --confirm
    git -C "$DEST" remote add origin "https://github.com/$REPO.git"
  fi
fi
if git -C "$DEST" rev-parse "$VERSION" >/dev/null 2>&1 || gh release view "$VERSION" --repo "$REPO" >/dev/null 2>&1; then echo "Tag/release $VERSION exists; refusing overwrite"; exit 1; fi
# Only upgrade files matching the archived v0.1.0 baseline; refuse divergent local customizations.
for rel in README.md app/index.html bin/deploy.sh docs/CHANGELOG.md data/atlas.json; do
  if [[ -e "$DEST/$rel" && ! -z "$(git -C "$DEST" rev-parse HEAD 2>/dev/null || true)" ]]; then
    if ! cmp -s "$DEST/$rel" "$ROOT/legacy/v0.2.0/$rel" && ! cmp -s "$DEST/$rel" "$ROOT/$rel"; then
      echo "Customized file differs from baseline: $rel; refusing overwrite"; exit 1
    fi
  fi
done
# Add only new files; refuse modifications to any existing tracked or untracked destination path.
while IFS= read -r -d '' src; do
  rel="${src#"$ROOT"/}"; [[ "$rel" == bin/deploy.sh ]] || true
  if [[ -e "$DEST/$rel" ]]; then
    if ! cmp -s "$src" "$DEST/$rel"; then
      case "$rel" in README.md|app/index.html|bin/deploy.sh|docs/CHANGELOG.md|data/atlas.json) ;; *) echo "Collision: $rel (refusing overwrite)"; exit 1;; esac
    fi
  fi
done < <(find "$ROOT" -type f -print0)
while IFS= read -r -d '' src; do
  rel="${src#"$ROOT"/}"; mkdir -p "$(dirname "$DEST/$rel")"; if [[ -e "$DEST/$rel" ]] && ! cmp -s "$src" "$DEST/$rel"; then
    case "$rel" in README.md|app/index.html|bin/deploy.sh|docs/CHANGELOG.md|data/atlas.json) cp "$src" "$DEST/$rel" ;; esac
  elif [[ ! -e "$DEST/$rel" ]]; then cp "$src" "$DEST/$rel"; fi
done < <(find "$ROOT" -type f -print0)
python3 "$DEST/tests/validate_v021.py" "$DEST"
git -C "$DEST" add .
if ! git -C "$DEST" diff --cached --quiet; then git -C "$DEST" commit -m "release: Native Nations Atlas $VERSION"; fi
git -C "$DEST" tag -a "$VERSION" -m "Native Nations Atlas $VERSION"
git -C "$DEST" push -u origin HEAD:main
git -C "$DEST" push origin "$VERSION"
gh release create "$VERSION" "$ROOT/../native-nations-atlas-v0.2.1.zip" --repo "$REPO" --title "Native Nations Atlas $VERSION" --notes-file "$ROOT/docs/CHANGELOG.md" 2>/dev/null || gh release create "$VERSION" --repo "$REPO" --title "Native Nations Atlas $VERSION" --notes-file "$ROOT/docs/CHANGELOG.md"
gh release view "$VERSION" --repo "$REPO" --json url,tagName
[[ "$(git -C "$DEST" ls-remote --tags origin "refs/tags/$VERSION" | wc -l | tr -d ' ')" == 1 ]]
echo "Verified: $REPO $VERSION"
