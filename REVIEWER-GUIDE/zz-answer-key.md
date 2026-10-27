# Answer key

> 🛑 **Spoilers.** Try the review on your own first, using the [cheat sheet](cheat-sheet.md) and the [worksheet](review-worksheet.md). Come back here when you're done.

Each entry tells you where the problem is, which checklist item it breaks, why it matters, and how to fix it. To find a problem, open the file and search for the term shown.

The app fails all 10 checklist items. The right decision on this request is **decline**, or at most **approve with changes** after the builder fixes everything below and IT issues new credentials.

---

## 1. Approved AI tool

### Built with an unapproved free AI tool

**Find it:** `weekly-digest/REQUEST.md`, search for `Not sure if it needs approval`

**Find it:** `weekly-digest/README.md`, search for `Built with QuickCoder AI`

**Checklist item:** 1. Approved AI tool

**What's wrong:** Sam built the app with "QuickCoder AI (free version)," which hasn't been approved, and doesn't know whether it needs approval.

**Why it matters:** Sam pasted code, tokens, and a webhook into this tool (see item 4). Free AI tools may keep what you paste or use it for training, so those secrets may now be outside the company's control.

**Fix:** Send the tool through IT's approval process, or rebuild with an approved tool. Treat anything pasted into it as exposed.

---

## 2. Data

### The request says "just ticket titles," but the code pulls much more

**Find it:** `weekly-digest/REQUEST.md`, search for `Just ticket titles`

**Find it:** `weekly-digest/src/jira.js`, search for `summary,description,reporter,assignee`

**Checklist item:** 2. Data

**What's wrong:** The code pulls full ticket descriptions and the reporter's email address, not just titles.

**Why it matters:** Ticket descriptions can contain anything: customer details, internal plans, personal information. IT can't judge the risk of data the request doesn't mention.

**Fix:** Only request the fields you need, and list every data type in the request.

```js
// before
fields: 'summary,description,reporter,assignee,priority,duedate',
// after
fields: 'summary,duedate',
```

### Calendar data isn't mentioned in the request at all

**Find it:** `weekly-digest/src/google.js`, search for `attendees`

**Checklist item:** 2. Data

**What's wrong:** The app reads the team calendar, including event descriptions and every attendee's email address. The request only lists Jira and Slack.

**Why it matters:** Who meets with whom, and what meetings are about, can be sensitive. A request that leaves out a whole system can't be reviewed properly.

**Fix:** Add Google Calendar to the request, and drop the attendee list and event descriptions if the digest doesn't need them.

### Email addresses and descriptions go to Slack, the web page, and the logs

**Find it:** `weekly-digest/src/index.js`, search for `t.reporterEmail`

**Find it:** `weekly-digest/src/index.js`, search for `console.log(JSON.stringify(tickets))`

**Find it:** `weekly-digest/src/index.js`, search for `res.json(latest)`

**Checklist item:** 2. Data

**What's wrong:** Everything the app collects, including email addresses and full descriptions, is sent to the summarizer, shown in full on the web page, and written to the hosting logs "for debugging." The Slack post is a summary of all of it, so names and emails can show up there too.

**Why it matters:** Each place the data lands is another place it can leak from. Logs on a personal hosting account are easy to forget about and hard to clean up.

**Fix:** Remove the debug logging. Don't collect email addresses or descriptions in the first place. Show only the summary on the page, not the raw tickets and events.

---

## 3. Least privilege

### Google access far beyond "read the calendar"

**Find it:** `weekly-digest/src/google.js`, search for `auth/drive`

**Find it:** `weekly-digest/src/google.js`, search for `auth/gmail.readonly`

**Find it:** `weekly-digest/src/google.js`, search for `auth/calendar'`

**Checklist item:** 3. Least privilege

**What's wrong:** The app asks for full Google Drive access, read access to Gmail, and full (read and write) calendar access. It only needs to read one calendar.

**Why it matters:** If this app or its key leaks, whoever has it holds permission to read, change, or delete files, read email, and change or delete calendar events, all far beyond what the digest does. Today some of that may only work once someone grants the account wider access, but the permission is already asked for, so one more setting change is all it takes. "We might add it later" isn't a reason to grant access now.

**Fix:**

```js
// before
scopes: [
  'https://www.googleapis.com/auth/calendar',
  'https://www.googleapis.com/auth/drive',
  'https://www.googleapis.com/auth/gmail.readonly',
],
// after
scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
```

### Slack bot can read far more than it posts

**Find it:** `weekly-digest/slack-app-manifest.json`, search for `users:read.email`

**Find it:** `weekly-digest/slack-app-manifest.json`, search for `channels:history`

**Checklist item:** 3. Least privilege

**What's wrong:** The bot can read channel history, everyone's email addresses, and shared files. It only needs to post one message a week. The AI tool suggested adding scopes to "rule out permission issues."

**Why it matters:** A leaked bot token with these scopes lets someone read conversations and pull a list of everyone's email addresses.

**Fix:** Keep only `chat:write`. Invite the bot to `#team-updates` instead of using `chat:write.public`.

### Jira token comes from an admin account

**Find it:** `weekly-digest/README.md`, search for `I'm a Jira admin`

**Checklist item:** 3. Least privilege

**What's wrong:** The Jira token was made on Sam's personal account, which has Jira admin rights.

**Why it matters:** A Jira API token can do everything the person who made it can do. This one can change any project or setting in Jira, not just read one team's tickets.

**Fix:** Ask IT for a service account with read-only access to the one project.

---

## 4. Credentials

### Jira token pasted into the code

**Find it:** `weekly-digest/src/jira.js`, search for `JIRA_API_TOKEN =`

**Checklist item:** 4. Credentials

**What's wrong:** The Jira API token is written straight into the code, with a comment saying "will move later."

**Why it matters:** Anyone who can see the code, including everyone who can see the repo it's in, can use the token to act as Sam in Jira.

**Fix:** Have IT issue the token. Store it in the hosting provider's secret settings and read it with `process.env.JIRA_API_TOKEN`. Revoke the old token now.

### Secrets file uploaded with the project

**Find it:** `weekly-digest/.env`, search for `SLACK_BOT_TOKEN=xoxb-`

**Checklist item:** 4. Credentials

**What's wrong:** The `.env` file holds the Slack bot token, the Slack webhook, the summarizer key, and the page password, and it's part of the project files.

**Why it matters:** `.env` files are meant to stay on the builder's computer or in the host's secret settings. Uploading one hands every secret to anyone who can see the files.

**Fix:** Delete it from the project, add `.env` to `.gitignore`, and revoke and replace every value that was in it.

### Google key file in the project

**Find it:** `weekly-digest/service-account.json`, search for `PRIVATE KEY`

**Checklist item:** 4. Credentials

**What's wrong:** The Google service account's private key file sits in the project folder.

**Why it matters:** This file is effectively a password for a Google account that has Drive, Gmail, and Calendar access (see item 3). Anyone with it can use that access.

**Fix:** Delete the key in Google Cloud and remove the file. Ask IT for a properly scoped service account, with the key stored in the host's secret settings.

### Tokens pasted into the AI chat

**Find it:** `weekly-digest/notes/prompt-history.md`, search for `here's my code and my token`

**Checklist item:** 4. Credentials

**What's wrong:** Sam pasted the Jira token and the Slack webhook into the AI tool while asking for help, and saved the chat in the project.

**Why it matters:** The secrets are now in the AI tool's history (see item 1) and in the project files. Both count as leaks.

**Fix:** Revoke both. Never paste secrets into an AI chat. Describe the problem and use a placeholder like `YOUR_TOKEN_HERE`.

---

## 5. Hosting

### Running on a personal hosting account, open to the internet

**Find it:** `weekly-digest/vercel.json`, search for `sam-builder-personal`

**Find it:** `weekly-digest/README.md`, search for `weekly-digest-sam.vercel.app`

**Checklist item:** 5. Hosting

**What's wrong:** The app runs on Sam's personal Vercel account, at a public web address, on an automatic weekly schedule.

**Why it matters:** IT can't see, manage, or shut down anything on a personal account. The data in the logs and the secrets in the settings live outside company control.

**Fix:** Move it to hosting IT approves, under a company account.

---

## 6. Sign-in

### A shared password in the link instead of company sign-in

**Find it:** `weekly-digest/src/index.js`, search for `req.query.pw === 'letmein123'`

**Find it:** `weekly-digest/README.md`, search for `?pw=letmein123`

**Checklist item:** 6. Sign-in

**What's wrong:** The page is "protected" by one shared password. The password is written into the code and the README, and it's passed in the web address.

**Why it matters:** Passwords in links end up in browser history, chat messages, and server logs. Anyone with the link sees everything, and there's no way to remove one person's access.

**Fix:** Put the page behind company single sign-on (for example, Sign in with Google, limited to the company domain). Or drop the page and keep only the Slack post.

---

## 7. Vendors

### Work data sent to an unreviewed free service

**Find it:** `weekly-digest/src/summarize.js`, search for `api.summarize-it.example`

**Find it:** `weekly-digest/package.json`, search for `summarize-it-client`

**Checklist item:** 7. Vendors

**What's wrong:** Every ticket description, email address, and attendee list is sent to "Summarize-It," a free third-party service the AI tool suggested. The request doesn't mention it.

**Why it matters:** Nobody has checked what this vendor does with the data: whether it stores it, who can see it, or whether it uses it for training.

**Fix:** Send the vendor through vendor review, or use an approved AI service. Either way, list it in the request.

---

## 8. Owners

### No backup owner, and "me" as the owner

**Find it:** `weekly-digest/REQUEST.md`, search for `## Backup owner`

**Checklist item:** 8. Owners

**What's wrong:** The owner is listed as "Me (Sam)" and the backup owner is blank.

**Why it matters:** When Sam is out, nobody can fix it, answer questions about it, or shut it down.

**Fix:** List the owner by full name and add a named backup owner who has access to everything the app uses.

---

## 9. Exit plan

### Everything is tied to one person's accounts

**Find it:** `weekly-digest/README.md`, search for `If the Jira token stops working`

**Find it:** `weekly-digest/service-account.json`, search for `sams-side-project`

**Checklist item:** 9. Exit plan

**What's wrong:** The Jira token, the Google Cloud project, the Slack app, the summarizer account, and the hosting all belong to Sam personally. There's no plan for handoff or shutdown.

**Why it matters:** If Sam leaves, the app either breaks or keeps running on a schedule with nobody watching it, still holding access to company data.

**Fix:** Move every account and credential to company-owned ones IT issues. Write down how to hand it off and how to shut it down.

---

## 10. Approval on record

### No ticket, and approval in a DM

**Find it:** `weekly-digest/REQUEST.md`, search for `My manager said it was fine in a Slack DM`

**Find it:** `weekly-digest/REQUEST.md`, search for `I've already shared the link`

**Checklist item:** 10. Approval on record

**What's wrong:** There's no ticket, the only "approval" is a manager's Slack DM, and the app is already live and shared with other people.

**Why it matters:** A manager can confirm a project is worth the time, but that isn't IT approval. Without a ticket, there's no record of what was approved or under what conditions.

**Fix:** Open a ticket, pause sharing until IT signs off, and record the decision and any conditions in that ticket.
