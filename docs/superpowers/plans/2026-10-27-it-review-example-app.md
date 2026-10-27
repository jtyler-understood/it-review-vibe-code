# IT Review Example App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a public training repo containing a deliberately flawed, vibe-coded "Weekly Team Digest" app plus a reviewer guide (cheat sheet, worksheet, answer key) that teaches IT to spot checklist violations.

**Architecture:** The app (`weekly-digest/`) is read-only training material; it is never run. Correctness is checked by one shell script, `scripts/verify.sh`, which enforces the public-repo safety rules (no internal names, only obviously fake secrets) and checks that every answer-key entry points to a file and search term that really exist. That script is the "test suite" for every task.

**Tech Stack:** Markdown; JavaScript/Node (CommonJS, never executed); bash + grep for verification.

**Spec:** `docs/superpowers/specs/2026-10-27-it-review-example-app-design.md`

## Global Constraints

- Generic wording only. Never write internal tool, form, system, or people names. The deny-list lives in a local, gitignored `.forbidden-terms` file that `scripts/verify.sh` reads, so the list itself is never published. Use the spec's "Generic review checklist" and "Generic request fields" text exactly.
- Placeholders only: `example.atlassian.net`, `example.org`, `#team-updates`, "Sam Builder", "Example Team", "QuickCoder AI", `api.summarize-it.example`.
- Every secret value contains `FAKE`, `EXAMPLE`, or `NOT-REAL`, while keeping the real format's shape (`xoxb-`, `https://hooks.slack.com/services/`, `ATATT`, the Google service-account JSON shape). The private key uses `-----BEGIN FAKE PRIVATE KEY-----`.
- No hint comments in app code (never "MISTAKE", "BAD", "INSECURE", "TODO: security"). Comments read like a builder's or AI tool's comments.
- Each file under `weekly-digest/src/` is 80 lines or fewer.
- Prose follows plain-language rules: short sentences, descriptive headings, jargon explained once.
- If GitHub push protection blocks a push, fix the value. Never bypass it.

## Review Focus

- A reviewer searching a cheat-sheet term finds nothing because the app spells it differently. Expect: every cheat-sheet search term hits at least one file in `weekly-digest/` (verify.sh check 5).
- An answer-key entry points to a search term that was edited away later. Expect: verify.sh check 3 fails.
- A fake secret that GitHub or scrapers would treat as real. Expect: verify.sh check 2 fails.
- A checklist item with no planted mistake. Expect: verify.sh check 4 fails.
- The answer key gets opened first by accident. Expect: the README and how-to-use.md both warn before linking to it, and the answer key opens with a spoiler warning.

---

### Task 1: Verification script, repo README, .gitignore

**Files:**
- Create: `scripts/verify.sh` (executable)
- Create: `README.md`
- Create: `.gitignore` (one line: `.project-sync-handoff.md`)

**Interfaces:**
- Produces: `scripts/verify.sh` exits 0 when all checks pass, non-zero otherwise, printing one `FAIL: <check>: <detail>` line per problem and `OK` on success. Later tasks run it as their test.
- Produces: the answer-key line formats that check 3 and check 4 parse (later tasks must use them exactly):
  - `**Find it:** \`<repo-relative path>\`, search for \`<literal string>\``
  - `**Checklist item:** <N>. <Generic item name>`
- Produces: the cheat-sheet line format that check 5 parses: `- Search for \`<term>\``

- [ ] **Step 1: Write `scripts/verify.sh`** with these checks (exclude `scripts/verify.sh`, `.git/`, and `docs/superpowers/` from checks 1 and 2, since the spec and plan quote the rules):
  1. Forbidden terms: case-insensitive match against every regex in the gitignored `.forbidden-terms` file, across the working tree and all git history. Any hit fails. (Revised after final review: the list was originally inline here and in the script, which would have published it.)
  2. Fake secrets: every secret-shaped value (a Slack/Atlassian/Google token prefix followed by a value, a Slack webhook path, or a private-key header) must also contain `FAKE`, `EXAMPLE`, or `NOT-REAL`. A private-key header without `FAKE` always fails.
  3. Answer-key references: for each `**Find it:**` line in `REVIEWER-GUIDE/answer-key.md`, extract the path and term. Fail if the file doesn't exist or `grep -F` finds no match. Fail if the answer key has zero `**Find it:**` lines.
  4. Checklist coverage: `REVIEWER-GUIDE/answer-key.md` must contain a `**Checklist item:** N.` line for every N from 1 to 10.
  5. Cheat-sheet terms: for each `- Search for \`<term>\`` line in `REVIEWER-GUIDE/cheat-sheet.md`, `grep -rF` the term across `weekly-digest/` (including dotfiles); fail if there's no hit.
  6. Length: fail on any `weekly-digest/src/*.js` file over 80 lines.
  7. Hint comments: fail on `grep -rniE 'MISTAKE|INSECURE|BAD PRACTICE|VULNERAB' weekly-digest/`.

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash scripts/verify.sh; echo "exit=$?"`
Expected: `FAIL: answer-key: ...missing` lines and `exit=1` (no answer key yet).

- [ ] **Step 3: Sanity-test checks 1 and 2** by creating a temporary file in `weekly-digest/` containing a realistic-looking Slack token and one forbidden term, running verify.sh, and confirming both a check 1 and a check 2 FAIL appear. Delete the temp file.

- [ ] **Step 4: Write `README.md`**: opens with a blockquote banner: "⚠️ This project is intentionally insecure. It's for training only. Don't copy, deploy, or reuse any of it." Then: what this is (two to three sentences), who it's for, how to use it (link to `REVIEWER-GUIDE/how-to-use.md`; say "don't open the answer key until you've tried"), a repo map, and a note that all names, keys, and URLs are fake.

- [ ] **Step 5: Commit**

```bash
git add scripts/verify.sh README.md .gitignore docs/
git commit -m "Add design, plan, verify script, and README"
```

### Task 2: The builder's paperwork and config files

**Files:** (all under `weekly-digest/`)
- Create: `REQUEST.md`, `README.md`, `notes/prompt-history.md`, `package.json`, `.env`, `service-account.json`, `slack-app-manifest.json`, `vercel.json`

**Interfaces:**
- Produces, for `src/` (Task 3) to reference by name: env vars `SLACK_BOT_TOKEN`, `SLACK_WEBHOOK_URL`, `SUMMARIZE_API_KEY`, `DIGEST_PASSWORD`; Google key path `./service-account.json`; `package.json` dependencies `googleapis`, `@slack/web-api`, `express`, `axios`, `summarize-it-client`.

Content each file must carry (mistake numbers refer to the spec's table):

- [ ] **Step 1: `REQUEST.md`**: written in Sam's voice, using the six generic request fields as headings, plus Owner / Backup owner / Ticket lines.
  - AI tool field says "QuickCoder AI (free version). Not sure if it needs approval" (#1).
  - Data field says "Just ticket titles" (#2).
  - Where it runs: "My Vercel account" (#5).
  - Owner: "Me (Sam)". Backup owner: left blank (#8).
  - Ticket: "TBD. My manager said it was fine in a Slack DM" (#10).
  - The work tools field lists only Jira and Slack. It leaves out Google Calendar and the summarizer, so the request undercounts (#2, #7).
- [ ] **Step 2: `README.md`** (builder's): a casual "how I set it up" page. It says it's on Sam's personal Vercel at a public URL, that Sam made a Jira token on their own admin account and a Google service account in a personal Google Cloud project, and it has no section on handoff or shutdown (#5, #9, #3).
- [ ] **Step 3: `notes/prompt-history.md`**: a short AI-chat excerpt where Sam pastes the Jira token and Slack webhook into the chat asking "why isn't this working" (#4).
- [ ] **Step 4: `.env`** with `SLACK_BOT_TOKEN=xoxb-FAKE-...`, `SLACK_WEBHOOK_URL=https://hooks.slack.com/services/TFAKE/BFAKE/EXAMPLEnotreal`, `SUMMARIZE_API_KEY=sk-summ-FAKE-...`, `DIGEST_PASSWORD=letmein123` (#4, #6).
- [ ] **Step 5: `service-account.json`**: real key-file field names (`type`, `project_id`, `private_key_id`, `private_key`, `client_email`, ...), with `project_id` `sams-side-project-EXAMPLE` and the FAKE private-key marker (#4, #9).
- [ ] **Step 6: `slack-app-manifest.json`**: bot scopes `chat:write`, `chat:write.public`, `channels:history`, `users:read`, `users:read.email`, `files:read` (#3).
- [ ] **Step 7: `vercel.json`**: a cron entry running `/api/digest` weekly; `package.json` has the dependencies listed above and `"author": "Sam Builder"` (#5, #7).
- [ ] **Step 8: Run `bash scripts/verify.sh`.** Expected: still fails only on the answer-key, cheat-sheet, and src checks. No check 1, 2, or 7 failures.
- [ ] **Step 9: Commit** `git add weekly-digest && git commit -m "Add builder paperwork and config for the flawed digest app"`

### Task 3: The app source

**Files:** `weekly-digest/src/index.js`, `jira.js`, `google.js`, `slack.js`, `summarize.js`

**Interfaces:**
- Consumes: env var names and file paths from Task 2.
- Produces (CommonJS exports, used by `index.js`): `getOpenTickets(): Promise<Ticket[]>` (jira.js), `getUpcomingEvents(): Promise<Event[]>` (google.js), `summarize(text: string): Promise<string>` (summarize.js), `postDigest(text: string): Promise<void>` (slack.js).

- [ ] **Step 1: `jira.js`**: a hardcoded `const JIRA_EMAIL = 'sam.builder@example.org'` and `const JIRA_API_TOKEN = 'ATATT-FAKE-...'`, with a comment like `// just hardcoding for now, will move later`. Base URL `https://example.atlassian.net`. The JQL fetches open tickets with fields `summary,description,reporter,assignee` (more than "titles", #2). Maps the reporter `emailAddress` into results (#2, #4).
- [ ] **Step 2: `google.js`**: `google.auth.GoogleAuth({ keyFile: './service-account.json', scopes: [...] })` with scopes `https://www.googleapis.com/auth/drive`, `https://www.googleapis.com/auth/gmail.readonly`, `https://www.googleapis.com/auth/calendar` (only `calendar.readonly` is needed). Returns events including the `attendees` emails (#3, #2, #4).
- [ ] **Step 3: `summarize.js`**: an `axios.post('https://api.summarize-it.example/v1/summarize', { text }, { headers: { Authorization: process.env.SUMMARIZE_API_KEY } })` that sends the full ticket and event text (#7, #2).
- [ ] **Step 4: `slack.js`**: uses both `@slack/web-api` with `SLACK_BOT_TOKEN` and a fallback `axios.post(process.env.SLACK_WEBHOOK_URL)` to `#team-updates`.
- [ ] **Step 5: `index.js`**: an Express app. `/api/digest` builds and posts the digest. `/` serves the latest digest (including reporter and attendee emails) behind a check `if (req.query.pw === process.env.DIGEST_PASSWORD || req.query.pw === 'letmein123')` (#6, #2). Add a `console.log(JSON.stringify(tickets))` "for debugging" (#2).
- [ ] **Step 6: Run `bash scripts/verify.sh`.** Expected: no check 1, 2, 6, or 7 failures. Only the answer-key and cheat-sheet checks fail.
- [ ] **Step 7: Commit** `git add weekly-digest/src && git commit -m "Add flawed digest app source"`

### Task 4: Reviewer guide (how-to-use, worksheet, cheat sheet)

**Files:** `REVIEWER-GUIDE/how-to-use.md`, `review-worksheet.md`, `cheat-sheet.md`

- [ ] **Step 1: `how-to-use.md`**: the exercise flow:
  1. Read `weekly-digest/REQUEST.md` as if it just arrived.
  2. Skim the code using the cheat sheet.
  3. Fill in the worksheet.
  4. Then open the answer key.
  - Add a short note that the cheat sheet works on real requests too, and a time estimate (about 30–45 minutes).
- [ ] **Step 2: `review-worksheet.md`**: the 10 generic checklist items exactly as written in the spec, each with "Pass / Fail / Can't tell", a "What I found" line, and a "Where" line.
- [ ] **Step 3: `cheat-sheet.md`**: one section per checklist item (10 sections, same generic names).
  - Each section has `- Search for \`<term>\`` lines and/or "Look for" lines, each followed by one plain line saying what a hit means.
  - Use search terms that are realistic for real reviews and that hit the app: `token`, `xoxb-`, `hooks.slack.com`, `PRIVATE KEY`, `.env`, `auth/drive`, `auth/gmail`, `scopes`, `http`, `password`, `vercel`, `console.log`.
  - For items that are paperwork-only (1, 8, 9, 10), use "Look for" guidance in the request, not search terms.
- [ ] **Step 4: Run `bash scripts/verify.sh`.** Expected: check 5 passes. Only the answer-key checks fail.
- [ ] **Step 5: Commit** `git add REVIEWER-GUIDE && git commit -m "Add reviewer how-to, worksheet, and cheat sheet"`

### Task 5: Answer key

**Files:** `REVIEWER-GUIDE/answer-key.md`

- [ ] **Step 1: Write the answer key.**
  - Open with a spoiler warning.
  - Add one `###` entry per planted mistake: every row of the spec's table, with each separate mistake in a row as its own entry, for about 15–18 entries.
  - Group entries under the 10 checklist items, in order.
  - Each entry has exactly these lines:
    - `**Find it:** \`<path>\`, search for \`<term>\``. Use a search term, not a line number. That's my call: search terms survive edits and suit skimmers. Use more than one Find it line if the mistake spans files.
    - `**Checklist item:** N. <name>`
    - `**What's wrong:**` in one or two sentences.
    - `**Why it matters:**` in one or two sentences, focused on internal-system risk.
    - `**Fix:**` as a short before/after code snippet, or one instruction such as "Ask IT to issue a service account and store the key in the host's secret settings, not in the repo."
- [ ] **Step 2: Run `bash scripts/verify.sh`.** Expected: `OK`, exit 0.
- [ ] **Step 3: Commit** `git add REVIEWER-GUIDE/answer-key.md && git commit -m "Add answer key"`

### Task 6: Final check and push (needs John's go-ahead)

- [ ] **Step 1:** Run `bash scripts/verify.sh`. Expected: `OK`.
- [ ] **Step 2:** Show John `git log --oneline` and the file tree. Ask before pushing.
- [ ] **Step 3:** On yes, run `git push -u origin main`. If push protection blocks it, report which value was flagged, fix it in a new commit, and ask again. Never bypass.
