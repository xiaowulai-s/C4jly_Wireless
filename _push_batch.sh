#!/bin/bash
# _push_batch.sh — add/commit/push one batch with dual-channel retries
# usage: _push_batch.sh "<commit message>"
cd "$(dirname "$0")" || exit 1
export GIT_TERMINAL_PROMPT=0
git add -A
if git diff --cached --quiet; then echo "BATCH_EMPTY"; exit 0; fi
git commit -m "$1" | tail -1
LOCAL=$(git rev-parse HEAD)
for i in 1 2 3 4 5 6 7 8; do
  if [ $((i % 2)) -eq 1 ]; then
    git -c http.proxy= -c https.proxy= push origin main 2>&1 | tail -1
  else
    git -c http.proxy=http://127.0.0.1:11682 -c https.proxy=http://127.0.0.1:11682 push origin main 2>&1 | tail -1
  fi
  REMOTE=$(git -c http.proxy=http://127.0.0.1:11682 ls-remote --heads origin 2>/dev/null | awk '{print $1}')
  if [ "$LOCAL" = "$REMOTE" ]; then echo "BATCH_OK"; exit 0; fi
  sleep 15
done
echo "BATCH_FAILED"
exit 1
