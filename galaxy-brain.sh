#!/usr/bin/env bash
# Crea discusiones Q&A, las responde y acepta la respuesta propia.
# Uso: TARGET=32 ./galaxy-brain.sh   (2 bronce, 8 plata, 16 oro, 32 diamante)
set -uo pipefail
cd "$(dirname "$0")"
TARGET="${TARGET:-32}"
REPO="KlGamers/insignias-git"
REPO_ID="R_kgDOUh0FZw"
CAT_ID="DIC_kwDOUh0FZ84DF-c3"

DONE="$(gh api graphql -f query='
query { repository(owner:"KlGamers", name:"insignias-git") {
  discussions(first:1){ totalCount }
} }' -q '.data.repository.discussions.totalCount')"
echo "Discusiones existentes: $DONE / objetivo $TARGET"

i=$((DONE+1))
while [ "$i" -le "$TARGET" ]; do
  D=$(gh api graphql -f query='
  mutation($repo:ID!, $cat:ID!, $title:String!, $body:String!) {
    createDiscussion(input:{repositoryId:$repo, categoryId:$cat, title:$title, body:$body}) {
      discussion { id }
    }
  }' -f repo="$REPO_ID" -f cat="$CAT_ID" -f title="Pregunta $i" -f body="Duda $i sobre el proyecto." 2>&1)
  DISC_ID=$(echo "$D" | python3 -c "import json,sys;print(json.load(sys.stdin)['data']['createDiscussion']['discussion']['id'])" 2>/dev/null)
  if [ -z "$DISC_ID" ]; then echo "Fallo creando discusión $i: $D"; sleep 30; continue; fi

  C=$(gh api graphql -f query='
  mutation($disc:ID!, $body:String!) {
    addDiscussionComment(input:{discussionId:$disc, body:$body}) {
      comment { id }
    }
  }' -f disc="$DISC_ID" -f body="Respuesta $i." 2>&1)
  COMMENT_ID=$(echo "$C" | python3 -c "import json,sys;print(json.load(sys.stdin)['data']['addDiscussionComment']['comment']['id'])" 2>/dev/null)
  if [ -z "$COMMENT_ID" ]; then echo "Fallo comentando $i: $C"; sleep 30; continue; fi

  gh api graphql -f query='
  mutation($id:ID!) { markDiscussionCommentAsAnswer(input:{id:$id}) { discussion { isAnswered } } }
  ' -f id="$COMMENT_ID" >/dev/null 2>&1

  echo "OK $i"
  i=$((i+1))
  sleep 2
done
echo "TERMINADO: $((i-1))"
