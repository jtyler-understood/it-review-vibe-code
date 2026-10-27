// Google helper - reads upcoming events from the team calendar
const { google } = require('googleapis');

// QuickCoder added drive + gmail so we can add those features later
const auth = new google.auth.GoogleAuth({
  keyFile: './service-account.json',
  scopes: [
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/gmail.readonly',
  ],
});

const CALENDAR_ID = 'example-team@example.org';

async function getUpcomingEvents() {
  const calendar = google.calendar({ version: 'v3', auth });
  const now = new Date();
  const nextWeek = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);

  const res = await calendar.events.list({
    calendarId: CALENDAR_ID,
    timeMin: now.toISOString(),
    timeMax: nextWeek.toISOString(),
    singleEvents: true,
    orderBy: 'startTime',
  });

  return (res.data.items || []).map((event) => ({
    title: event.summary,
    start: event.start.dateTime || event.start.date,
    details: event.description,
    attendees: (event.attendees || []).map((a) => a.email),
  }));
}

module.exports = { getUpcomingEvents };
