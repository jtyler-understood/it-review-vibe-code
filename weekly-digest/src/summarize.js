// Summarizer - turns the raw tickets and events into a short digest
// Uses Summarize-It (free tier) because it was the easiest to set up
const axios = require('axios');

const SUMMARIZE_URL = 'https://api.summarize-it.example/v1/summarize';

async function summarize(text) {
  const res = await axios.post(
    SUMMARIZE_URL,
    { text, style: 'bullet-points', length: 'short' },
    { headers: { Authorization: process.env.SUMMARIZE_API_KEY } }
  );
  return res.data.summary;
}

module.exports = { summarize };
