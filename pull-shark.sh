#!/usr/bin/env bash
# Uso: TARGET=128 ./pull-shark.sh  -> abre y fusiona PRs hasta llegar a TARGET fusionados
set -uo pipefail
cd "$(dirname "$0")"
TARGET="${TARGET:-128}"
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
CO_AUTHOR="${CO_AUTHOR:-Claude Sonnet 5 <noreply@anthropic.com>}"
DONE="$(gh pr list --repo "$REPO" --state merged --limit 2000 --json number -q length)"
echo "Fusionados: $DONE / $TARGET"
mkdir -p logs
while [ "$DONE" -lt "$TARGET" ]; do
  git checkout -q main && git pull -q origin main
  N=$((DONE+1)); BR="badge/ps-$N-$(date +%s)"
  git checkout -q -b "$BR"
  echo "PR $N $(date -u +%FT%TZ)" > "logs/ps-$N-$(date +%s).md"
  git add logs
  git commit -q -m "Add log entry $N

Co-Authored-By: ${CO_AUTHOR}"
  git push -q -u origin "$BR" 2>/dev/null
  if gh pr create --repo "$REPO" --head "$BR" --base main --title "Log entry $N" \
       --body "🤖 Generated with [Claude Code](https://claude.com/claude-code)" >/dev/null \
     && gh pr merge "$BR" --repo "$REPO" --merge --delete-branch >/dev/null; then
    DONE=$((DONE+1)); echo "OK $DONE"
  else
    echo "Fallo en $N, esperando 60s"; sleep 60
  fi
  sleep 2
done
git checkout -q main && git pull -q origin main
echo "TERMINADO: $DONE"
