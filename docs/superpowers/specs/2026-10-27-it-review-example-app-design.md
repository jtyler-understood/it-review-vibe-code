# Design: Deliberately Flawed Vibe-Coded App for IT Review Training

Date: 2026-10-27
Owner: John Tyler
Repo: `jtyler-understood/it-review-vibe-code` (public, personal account for now; to be transferred to the Understood GitHub org once org access is restored)

## Why this exists

Our IT team uses a short review checklist for every vibe-coded project request. The checklist is abstract ("use least privilege"). Reviewers need to see what a violation of each item actually looks like in a real project before they can spot it reliably.

This repo is a practice target: a small, realistic, intentionally insecure app that a non-developer might vibe-code, with the kind of mistakes IT will actually run into. Reviewers inspect it, try to find the problems, then check their findings against an answer key.

### Public-repo rule: generic wording only

While this repo is public, it must not quote internal process documents or name internal tools, forms, or systems (no SOP title or link, no internal request-form names, no internal vendor-review tool names). Use the generic checklist and request fields below everywhere. When the repo moves into the private Understood org, these can be swapped for the real wording and an SOP link.

### Generic review checklist (use this wording in all materials)

1. **Approved AI tool:** The AI tool used to build it is approved, or is going through IT's approval process.
2. **Data:** The data it touches is listed, and sensitive data is avoided or approved.
3. **Least privilege:** It only has the permissions it actually needs.
4. **Credentials:** Keys and tokens come from IT and are stored safely, never pasted into code or AI chats.
5. **Hosting:** It runs somewhere IT has approved.
6. **Sign-in:** People sign in with company single sign-on (SSO) where possible.
7. **Vendors:** Any outside services it sends data to have been through vendor review.
8. **Owners:** It has a named owner and a backup owner.
9. **Exit plan:** There's a plan to shut it down or hand it off if the owner leaves.
10. **Approval on record:** IT's approval and any conditions are recorded in the request ticket.

### Generic request fields (the sections of `REQUEST.md`)

1. What it does and the problem it solves
2. The AI tool used to build it
3. The data it touches
4. The work tools it connects to
5. Who will use it
6. Where it runs

`REQUEST.md` also has lines for owner, backup owner, and ticket/approval, since checklist items 8 and 10 look for them. General good-practice rules (don't paste keys into AI tools, don't create your own keys or admin access, don't share before sign-off) are fair game for the answer key's "why it matters" lines.

## Audience

IT team members with mixed coding knowledge. Most will **skim for patterns**, not read code line by line. Every learning aid must work for someone who can't follow the code's logic but can search for strings and recognize shapes (a long random-looking string, a scope URL, a file that shouldn't be there).

## Goals

- Every one of the 10 checklist items is violated at least once, in a way a skimming reviewer can find.
- Focus on how the project touches **internal systems**: Google Workspace, Slack, and Jira.
- A plain-English cheat sheet of patterns to search for, reusable on real requests after training.
- An answer key: for each planted mistake, where it is, which checklist line it breaks, why it matters (one or two sentences), and what the fix looks like.
- Code that looks like a real vibe-coded project (realistic library calls, scopes, and config files), so the patterns transfer to real reviews.

## Non-goals

- The app does not need to run. Readable code is enough. No real or stand-in services, no install or deploy instructions.
- No complete "fixed" version of the app. Fixes are shown as short before/after snippets in the answer key.
- Not a general secure-coding course. Mistakes outside the checklist's scope (XSS, SQL injection, etc.) are out unless they relate directly to internal-system access.

## Anti-goals (would make this a failure even if it "works")

- **Anything real leaks into a public repo.** No real credentials, no real Understood URLs, domains, Slack channel names, or people's names. All secrets must be *obviously fake* (e.g. `xoxb-FAKE-0000-EXAMPLE`) so they don't trip GitHub secret scanning or attract credential-scraping bots, and so nobody mistakes them for real ones.
- **Someone copies it as a template.** The README must open with a clear "intentionally insecure, for training only" banner.
- **Hints in the code give the game away.** Code comments should read like a builder's or AI tool's comments ("// quick fix, will clean up later"), never "// MISTAKE #3".
- **It's too hard for a skimming reviewer.** If a mistake can only be found by understanding control flow, it doesn't belong here.

## The example app: "Weekly Team Digest"

A Node.js script (with a tiny web page) that a fictional builder, "Sam Builder" on the "Example Team," made with an AI coding tool on a Friday afternoon. Every week it:

1. Pulls the team's open Jira tickets.
2. Reads upcoming events and deadlines from Google Calendar.
3. Sends ticket and event text to a third-party AI summarization API.
4. Posts the summary to a Slack channel.
5. Serves a small "latest digest" web page.

All names are placeholders: `example.atlassian.net`, `example.org`, `#team-updates`, "Sam Builder."

**Language: JavaScript/Node.** This was my call: it's what tools like Cursor, Replit, Lovable, and v0 most often produce.

## Repo layout

```
README.md                      Banner, what this is, how to use it
REVIEWER-GUIDE/
  how-to-use.md                Suggested exercise flow (try first, then check the key)
  cheat-sheet.md               Plain-English patterns to search for, grouped by checklist item
  review-worksheet.md          Blank copy of the 10-item checklist for reviewers to fill in
  answer-key.md                One entry per planted mistake (spoilers; README warns)
weekly-digest/                 The flawed app, as the builder would submit it
  REQUEST.md                   The builder's request, using the 6 generic request fields
  README.md                    Builder's own README (owner, hosting, notes)
  package.json
  .env                         Committed by mistake
  service-account.json         Google service-account key, committed (fake)
  slack-app-manifest.json      Slack app scopes
  vercel.json                  Hosting config, personal account + cron
  notes/prompt-history.md      Excerpt of the builder's AI chat, with a pasted token
  src/index.js                 Entry point and web page
  src/jira.js
  src/google.js
  src/slack.js
  src/summarize.js
```

## Planted mistakes, mapped to the checklist

Each checklist item gets at least one mistake. The table is the minimum set; the builder may add a small number of closely related extras if they fit naturally.

| # | Checklist item | Planted mistake(s) | Where |
|---|---|---|---|
| 1 | AI tool is approved or in review | Built with a fictional unapproved tool ("QuickCoder AI," free tier); request says "not sure if it needs approval" | `REQUEST.md`, `README.md` |
| 2 | Data types listed; sensitive data avoided or approved | Request says "just ticket titles." Code actually pulls full ticket descriptions, reporter emails, and calendar attendee lists, and posts them to Slack and the public web page | `REQUEST.md` vs `src/jira.js`, `src/google.js`, `src/index.js` |
| 3 | Least privilege | Google scopes request full `auth/drive`, `auth/gmail.readonly`, and `auth/calendar` instead of only `auth/calendar.readonly`. Slack manifest asks for `channels:history`, `users:read.email`, `chat:write.public`, `files:read` when only `chat:write` is needed. Jira uses a Jira admin's personal token | `src/google.js`, `slack-app-manifest.json`, `src/jira.js`, `.env` |
| 4 | Credentials issued by IT and stored safely | Jira API token hardcoded in `src/jira.js`; `.env` committed with Slack bot token and webhook URL; Google service-account key file committed; token pasted into AI chat history | `src/jira.js`, `.env`, `service-account.json`, `notes/prompt-history.md` |
| 5 | Hosting approved | Deployed to the builder's personal Vercel account; the web page is public on the internet | `vercel.json`, `README.md` |
| 6 | SSO where possible | Digest page is protected by a hardcoded shared password instead of Google SSO (my call: a password, not "nothing," so this doesn't overlap with mistake 5) | `src/index.js` |
| 7 | Vendors reviewed | Ticket and calendar text sent to an unreviewed free AI summarization API (`api.summarize-it.example`) | `src/summarize.js`, `package.json` |
| 8 | Named owner and backup owner | Builder README says "Owner: me (Sam)"; no backup | `README.md`, `REQUEST.md` |
| 9 | Plan for shutdown or handoff | None. All credentials are tied to Sam's personal accounts, so it either breaks or keeps running unmonitored if Sam leaves | `README.md`, `.env` |
| 10 | Approval and conditions recorded in ticket | "Ticket: TBD. My manager said it was fine in a Slack DM" | `REQUEST.md` |

## Fake secrets

- Every secret uses an obvious fake marker: `FAKE`, `EXAMPLE`, or `NOT-REAL` inside the value. They should still *look* like the real format (e.g. Slack tokens start with `xoxb-`, Jira tokens are long strings, the Google key file has the real JSON shape) so reviewers learn to recognize the shape.
- The private key in `service-account.json` uses `-----BEGIN FAKE PRIVATE KEY-----` and filler content so it won't match secret-scanning patterns.
- Before pushing, run a check that no value matches a real token format without the fake marker. If GitHub push protection blocks a push, fix the value. Don't bypass the block.

## Cheat sheet (shape)

Grouped by checklist item. Each entry is a search term or visual pattern plus one line of "what it means." Examples:

- Search for `token`, `key`, `secret`, `password`, `xoxb-`, `hooks.slack.com`, `PRIVATE KEY` (not the full key header, which would miss the fake key's marker). A long random-looking string next to these = a credential in code.
- A file named `.env` or ending in `.json` with `private_key` in the repo = secrets committed.
- Google scope URLs: anything without `.readonly` at the end, or `drive`/`gmail` when the app has nothing to do with files or email = too much access.
- Any `fetch(`/`axios` call to a domain that isn't Google, Slack, or Atlassian = an outside vendor that needs vendor review.

Written so it's reusable on real requests, not only this repo.

## Answer key (shape)

One entry per planted mistake:

- **Where:** file and line
- **Checklist item:** number and text
- **What's wrong:** one or two plain sentences
- **Why it matters:** one or two plain sentences, focused on the internal-system risk
- **Fix:** short before/after snippet or a one-line instruction (e.g. "Ask IT for a service account; store the token in the hosting provider's secret settings")

## Writing standards

Follow Understood's accessible writing standards for all prose (README, guide, cheat sheet, answer key): plain language, short sentences, descriptive headings, no jargon without a short explanation.

## Left to the builder

- Exact wording of code, comments, and the builder's documents, as long as they read like a real non-developer's vibe-coded project.
- Whether to add one or two extra realistic mistakes beyond the table, as long as each maps to a checklist item and is findable by skimming.
- File line counts. Keep each source file short (aim for under ~80 lines).
