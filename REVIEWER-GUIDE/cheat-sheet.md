# Cheat sheet: what to look for

You don't need to understand the code to use this. Search the project for each term. If you get a hit, read the line around it and check it against the note below.

This works on real requests too, not just this practice app.

## Before you start: compare the request to the project

Read the builder's request first. Then, as you search, keep asking: **does the code do more than the request says?** More data, more tools, or more access than the request lists is a red flag on its own.

## 1. Approved AI tool

- Look for the name of the AI tool in the request and the project's README. Check it against IT's list of approved tools.
- Look for phrases like "free version," "not sure if it needs approval," or "everyone uses it." Free tiers of AI tools often keep or train on what you paste into them.

## 2. Data

- Search for `description`. Ticket and event descriptions often hold far more than titles: customer details, internal plans, personal information.
- Search for `email`. Email addresses are personal data. Check whether the request mentions them.
- Search for `attendees`. Calendar attendee lists show who meets with whom.
- Search for `console.log`. This writes data to the hosting provider's logs, where more people may be able to see it.
- Look for whatever the app shows on a web page or posts to a channel. That data now goes to everyone who can see the page or channel.

## 3. Least privilege

- Search for `scopes`. This is where an app lists what it's allowed to do.
- Search for `auth/drive`. Full Google Drive access means it can read, change, and delete every file the account can reach. A calendar app doesn't need it.
- Search for `auth/gmail`. Gmail access means it can read email. Ask why.
- Search for `auth/calendar`. If the scope doesn't end in `.readonly`, the app can change or delete events, not just read them.
- Search for `users:read.email`, `channels:history`, and `files:read`. These Slack permissions let a bot read people's email addresses, channel messages, and shared files. A bot that only posts needs only `chat:write`.
- Look for the word "admin" anywhere near a token or account. A token made by an admin can do everything that admin can do.

## 4. Credentials

- Search for `token`. A long, random-looking string next to it is probably a real credential in the code.
- Search for `xoxb-`. That's what a Slack bot token starts with.
- Search for `ATATT`. That's what an Atlassian (Jira) API token usually starts with.
- Search for `hooks.slack.com`. That's a Slack webhook. Anyone who has the link can post to the channel.
- Search for `PRIVATE KEY`. A private key in a project file means anyone with the files can act as that account.
- Look for a file named `.env` (on GitHub, press `t` and type `.env`). It usually holds secrets and should never be shared or uploaded with the project.
- Seeing `process.env.SOMETHING` in the code is fine. That's the safe way for code to read a secret from the host's settings instead of the files.
- Search for `service-account`. A Google service account key file is a password for a Google account.
- Look in notes and chat logs saved in the project. Builders often paste tokens into AI chats while asking for help.

## 5. Hosting

- Search for `vercel`. Also check for other hosts like Replit, Netlify, Render, Heroku, or Glitch. Then check whose account it's on: a personal account isn't approved hosting.
- Search for `crons`. Scheduled jobs keep running on their own, even if nobody is watching them.
- Look for a web address ending in `.vercel.app`, `.replit.app`, `.netlify.app`, or similar. That means it's on the public internet.

## 6. Sign-in

- Search for `password`. A shared password in the code or the README isn't sign-in. Anyone who sees it gets in.
- Search for `pw=`. A password in a web address gets saved in browser history and shared links.
- Look for "Sign in with Google" or SSO. If people use the app and there's no company sign-in, flag it.

## 7. Vendors

- Search for `https://`. Every web address in the code is a service the app talks to. Anything that isn't Google, Slack, or Atlassian is an outside vendor that needs review.
- Search for `axios`. This is a common way for code to send data to a web address. Check where it sends it.
- Look at the `dependencies` list in `package.json` for packages named after a company or service you don't recognize.

## 8. Owners

- Look for an owner and a backup owner in the request. "Me" isn't enough. A blank backup owner is a fail.

## 9. Exit plan

- Look for a section on handoff or shutdown in the request or README. If it's missing, that's a fail.
- Look for credentials tied to one person's account: their personal token, their personal Google Cloud project, their personal hosting. If that person leaves, the app either breaks or keeps running with nobody watching it.

## 10. Approval on record

- Look for a ticket number in the request. "TBD," "my manager said it's fine," or approval in a chat message doesn't count.
- Look for signs it's already live or already shared. That means it skipped review.
