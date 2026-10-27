// Jira helper - gets our team's open tickets
const axios = require('axios');

const JIRA_BASE_URL = 'https://example.atlassian.net';

// just hardcoding for now, will move later
const JIRA_EMAIL = 'sam.builder@example.org';
const JIRA_API_TOKEN = 'ATATT-FAKE-3xampleT0kenNOT-REAL-sam-builder-0001';

const auth = Buffer.from(`${JIRA_EMAIL}:${JIRA_API_TOKEN}`).toString('base64');

async function getOpenTickets() {
  const res = await axios.get(`${JIRA_BASE_URL}/rest/api/3/search`, {
    headers: { Authorization: `Basic ${auth}`, Accept: 'application/json' },
    params: {
      jql: 'project = TEAM AND statusCategory != Done ORDER BY priority DESC',
      fields: 'summary,description,reporter,assignee,priority,duedate',
      maxResults: 100,
    },
  });

  return res.data.issues.map((issue) => ({
    key: issue.key,
    title: issue.fields.summary,
    description: issue.fields.description,
    reporter: issue.fields.reporter?.displayName,
    reporterEmail: issue.fields.reporter?.emailAddress,
    assignee: issue.fields.assignee?.displayName,
    due: issue.fields.duedate,
  }));
}

module.exports = { getOpenTickets };
