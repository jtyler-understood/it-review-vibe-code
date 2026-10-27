#!/usr/bin/env bash
# Safety and consistency checks for this training repo.
# Run from anywhere: bash scripts/verify.sh
# Prints one "FAIL: <check>: <detail>" line per problem, or "OK".

cd "$(dirname "$0")/.." || exit 2

fails=0
fail() { echo "FAIL: $1: $2"; fails=$((fails + 1)); }

KEY=REVIEWER-GUIDE/zz-answer-key.md
CHEAT=REVIEWER-GUIDE/cheat-sheet.md
APP=weekly-digest

# Files checked for leaks: everything in the repo except git internals and
# local-only scratch files.
scan_files() {
  find . -type f \
    -not -path './.git/*' \
    -not -path './.superpowers/*' \
    -not -path './scripts/verify.sh' \
    -not -name '.project-sync-handoff.md' \
    -not -name '.forbidden-terms'
}

# 1. Internal names must never appear while the repo is public. The list lives
#    in .forbidden-terms (one regex per line), which is gitignored so the list
#    itself is never published. Checks the working tree and all git history.
TERMS=.forbidden-terms
if [[ ! -s $TERMS ]]; then
  echo "WARN: $TERMS missing, skipping internal-name checks"
else
  while IFS= read -r hit; do
    fail "internal-name" "$hit"
  done < <(scan_files | xargs grep -HniEf "$TERMS" 2>/dev/null)
  while IFS= read -r hit; do
    fail "internal-name-in-history" "$hit"
  done < <(git log -p --all 2>/dev/null | grep -niEf "$TERMS")
fi

# 2. Any secret-shaped value (a known prefix followed by a value) must carry
#    an obvious fake marker. A bare prefix in prose, like `xoxb-`, is fine.
while IFS= read -r hit; do
  line=${hit#*:*:}
  if ! grep -qE 'FAKE|EXAMPLE|NOT-REAL' <<<"$line"; then
    fail "real-looking-secret" "$hit"
  fi
done < <(scan_files | xargs grep -HnE 'xox[bpa]-[A-Za-z0-9-]{8,}|hooks\.slack\.com/services/[A-Za-z0-9]|ATATT[A-Za-z0-9_-]{8,}|AIza[A-Za-z0-9_-]{8,}|BEGIN [A-Z ]*PRIVATE KEY' 2>/dev/null)
while IFS= read -r hit; do
  fail "real-private-key-header" "$hit"
done < <(scan_files | xargs grep -Hn 'BEGIN PRIVATE KEY' 2>/dev/null)

# Slack webhook paths of 40+ letters/digits match common leak scanners even with
# FAKE inside. Fake webhooks must break the shape with hyphens.
while IFS= read -r hit; do
  fail "scanner-shaped-webhook" "$hit"
done < <(scan_files | xargs grep -HnE 'hooks\.slack\.com/services/[A-Za-z0-9/]{40,}' 2>/dev/null)

# 3. Every answer-key "Find it" line must point at a real file and a real string.
if [[ ! -f $KEY ]]; then
  fail "answer-key" "$KEY missing"
else
  refs=$(grep -c '^\*\*Find it:\*\*' "$KEY")
  [[ $refs -eq 0 ]] && fail "answer-key" "no **Find it:** lines"
  while IFS= read -r line; do
    path=$(sed -E 's/^\*\*Find it:\*\* `([^`]+)`.*/\1/' <<<"$line")
    term=$(sed -E 's/.*search for `([^`]+)`.*/\1/' <<<"$line")
    if [[ ! -f $path ]]; then
      fail "answer-key" "file not found: $path"
    elif ! grep -qF -- "$term" "$path"; then
      fail "answer-key" "'$term' not found in $path"
    fi
  done < <(grep '^\*\*Find it:\*\*' "$KEY")
fi

# 4. Every checklist item 1-10 has at least one answer-key entry.
if [[ -f $KEY ]]; then
  for n in 1 2 3 4 5 6 7 8 9 10; do
    grep -qE "^\*\*Checklist item:\*\* $n\. " "$KEY" || fail "coverage" "no entry for checklist item $n"
  done
fi

# 5. Every cheat-sheet search term finds something in the app.
if [[ ! -f $CHEAT ]]; then
  fail "cheat-sheet" "$CHEAT missing"
else
  while IFS= read -r term; do
    grep -rqF -- "$term" "$APP" || fail "cheat-sheet" "'$term' finds nothing in $APP/"
  done < <(sed -nE 's/^- Search for `([^`]+)`.*/\1/p' "$CHEAT")
fi

# 6. Source files stay short enough to skim.
for f in "$APP"/src/*.js; do
  [[ -f $f ]] || { fail "length" "no source files in $APP/src"; break; }
  n=$(wc -l <"$f")
  [[ $n -gt 80 ]] && fail "length" "$f has $n lines (max 80)"
done

# 7. No comments that give the planted mistakes away.
while IFS= read -r hit; do
  fail "hint-comment" "$hit"
done < <(grep -rniE 'MISTAKE|INSECURE|BAD PRACTICE|VULNERAB' "$APP" 2>/dev/null)

if [[ $fails -eq 0 ]]; then
  echo "OK"
  exit 0
fi
exit 1
