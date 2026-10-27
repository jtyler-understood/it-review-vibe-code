# IT review practice: a vibe-coded app with planted mistakes

> ⚠️ **This project is intentionally insecure. It's for training only.**
> Don't copy, deploy, or reuse any of it. Every name, key, token, and web address in it is fake.

## What this is

"Vibe coding" means using an AI tool to build an app, even if you aren't a developer. More and more people do it, and many of these apps connect to work tools like Google Workspace, Slack, and Jira.

This repo is practice material for the IT reviewers who check those projects. It holds a small app called **Weekly Team Digest**, written the way a busy, well-meaning builder might write it with an AI tool on a Friday afternoon. It works, but it breaks every item on IT's review checklist at least once.

Your job is to find the problems.

## Who it's for

IT team members who review vibe-coded projects. You don't need to read code fluently. Most of the mistakes can be found by searching for a word or spotting a file that shouldn't be there.

## How to use it

1. Start with the [how-to guide](REVIEWER-GUIDE/how-to-use.md). It walks you through the exercise in about 30 to 45 minutes.
2. Use the [cheat sheet](REVIEWER-GUIDE/cheat-sheet.md) and fill in the [review worksheet](REVIEWER-GUIDE/review-worksheet.md) as you go.
3. **Don't open the answer key until you've tried.** It's the last file in the `REVIEWER-GUIDE` folder, `zz-answer-key.md`, so you won't land on it by accident.

## What's in here

| Folder or file | What it is |
|---|---|
| `weekly-digest/` | The app, exactly as the builder would hand it to IT |
| `weekly-digest/REQUEST.md` | The builder's request to IT. Start here. |
| `REVIEWER-GUIDE/` | How-to guide, cheat sheet, worksheet, and answer key |
| `scripts/verify.sh` | A check we run before publishing to make sure nothing real slipped in |
| `docs/` | The design and build plan for this repo |

## About the fake secrets

The app is full of things that look like passwords, tokens, and keys. They're all fake, and each one contains the word `FAKE`, `EXAMPLE`, or `NOT-REAL`. They keep the shape of real ones so you learn what to look for.

If you ever find something like this in a real project, treat it as a leak and tell IT right away.
