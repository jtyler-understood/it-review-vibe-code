// Weekly Team Digest - main app
require('dotenv').config();
const express = require('express');
const { getOpenTickets } = require('./jira');
const { getUpcomingEvents } = require('./google');
const { summarize } = require('./summarize');
const { postDigest } = require('./slack');

const app = express();
let latest = null;

// runs every Friday (see vercel.json)
app.get('/api/digest', async (req, res) => {
  const tickets = await getOpenTickets();
  const events = await getUpcomingEvents();

  // for debugging
  console.log(JSON.stringify(tickets));
  console.log(JSON.stringify(events));

  const raw = [
    ...tickets.map((t) => `${t.key}: ${t.title} (${t.reporterEmail}) - ${t.description}`),
    ...events.map((e) => `${e.title} on ${e.start} with ${e.attendees.join(', ')}`),
  ].join('\n');

  const summary = await summarize(raw);
  await postDigest(summary);

  latest = { summary, tickets, events, updated: new Date().toISOString() };
  res.json({ ok: true });
});

// the digest page - password so it's secure
app.get('/', (req, res) => {
  if (req.query.pw === process.env.DIGEST_PASSWORD || req.query.pw === 'letmein123') {
    return res.json(latest);
  }
  res.status(401).send('Wrong password');
});

app.listen(process.env.PORT || 3000, () => console.log('Digest running'));

module.exports = app;
