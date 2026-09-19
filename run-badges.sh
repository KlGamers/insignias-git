#!/usr/bin/env bash
# Crea un repo PRIVADO en tu perfil y genera la actividad necesaria para las
# insignias de GitHub que se pueden conseguir en solitario.
#
# Uso:   ./run-badges.sh
# Vars:  REPO_NAME (insignias-git)  PRS (2)  CO_AUTHOR ("Nombre <email>")
set -euo pipefail
cd "$(dirname "$0")"

REPO_NAME="${REPO_NAME:-insignias-git}"
PRS="${PRS:-2}"   # 2 = Pull Shark bronce, 16 = plata, 128 = oro
CO_AUTHOR="${CO_AUTHOR:-Claude Sonnet 5 <noreply@anthropic.com>}"

command -v gh >/dev/null || { echo "Instala gh: brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Inicia sesión: gh auth login"; exit 1; }
[ -d .git ] || git init -q -b main

LOGIN="$(gh api user -q .login)"
ID="$(gh api user -q .id)"
git config user.name "$LOGIN"
git config user.email "${ID}+${LOGIN}@users.noreply.github.com"

TRAILER="Co-Authored-By: ${CO_AUTHOR}"
PR_FOOTER="🤖 Generated with [Claude Code](https://claude.com/claude-code)"

# 1. Repo privado + commit inicial
[ -d .git ] || git init -b main
git add -A
git diff --cached --quiet || git commit -m "Initial commit

${TRAILER}"
if ! git remote get-url origin >/dev/null 2>&1; then
  gh repo create "$REPO_NAME" --private --source=. --remote=origin --push
fi
REPO="$LOGIN/$REPO_NAME"
gh repo edit "$REPO" --enable-discussions >/dev/null || true

# 2. Pull Shark + YOLO + Pair Extraordinaire:
#    PRs propios fusionados sin revisión, con commit co-autorado.
mkdir -p logs
for i in $(seq 1 "$PRS"); do
  git checkout -q main && git pull -q origin main
  BR="badge/pr-$(date +%s)-$i"
  git checkout -q -b "$BR"
  echo "PR $i - $(date -u +%FT%TZ)" > "logs/pr-$i-$(date +%s).md"
  git add logs
  git commit -q -m "Add log entry $i

${TRAILER}"
  git push -q -u origin "$BR"
  gh pr create --repo "$REPO" --head "$BR" --base main \
    --title "Log entry $i" --body "Automated badge PR $i.

${PR_FOOTER}"
  gh pr merge "$BR" --repo "$REPO" --merge --delete-branch
done
git checkout -q main && git pull -q origin main

# 3. Quickdraw (cerrar en <5 min) + Heart On Your Sleeve (reacciones)
N="$(gh issue create --repo "$REPO" --title "Quickdraw" \
      --body "Se cierra de inmediato." | grep -o '[0-9]*$')"
for r in heart rocket hooray "+1"; do
  gh api "repos/$REPO/issues/$N/reactions" -f content="$r" >/dev/null || true
done
gh issue close "$N" --repo "$REPO"

echo "Listo: https://github.com/$REPO"
