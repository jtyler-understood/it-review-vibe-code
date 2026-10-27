# Weekly Team Digest 🗞️

Posts a summary of our open Jira tickets and upcoming calendar stuff to Slack every Friday.

Built with QuickCoder AI. I don't really code, so QuickCoder wrote most of this. It works great!

## How I set it up

1. **Jira:** I made an API token on my own Atlassian account (I'm a Jira admin from when I set up our board) and put it in `src/jira.js`.
2. **Google Calendar:** I made a Google Cloud project on my personal account ("sams-side-project"), turned on the APIs QuickCoder told me to, and downloaded the service account key. It's `service-account.json` in this folder.
3. **Slack:** I made a Slack app and installed it to the workspace myself. The bot token and webhook are in `.env`.
4. **Summaries:** QuickCoder suggested a free summarizing service called Summarize-It, so I signed up and got an API key. Also in `.env`.
5. **Hosting:** It's deployed on my personal Vercel account. The cron in `vercel.json` runs it every Friday at 9am.

## The digest page

It's public at `https://weekly-digest-sam.vercel.app` so anyone can check it. Add `?pw=letmein123` to the end of the link to see it. I put a password on it so it's secure.

## Owner

Me! Message me if it breaks.

## Notes

- If the Jira token stops working, it's probably because I changed my password. Just ping me.
- I want to add Gmail next so it can pull in important emails too. That's why it already has Gmail access.
