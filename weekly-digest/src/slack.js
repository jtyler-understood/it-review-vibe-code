// Slack helper - posts the digest to our channel
const { WebClient } = require('@slack/web-api');
const axios = require('axios');

const slack = new WebClient(process.env.SLACK_BOT_TOKEN);
const CHANNEL = '#team-updates';

async function postDigest(text) {
  try {
    await slack.chat.postMessage({ channel: CHANNEL, text });
  } catch (err) {
    // bot sometimes fails, webhook always works
    await axios.post(process.env.SLACK_WEBHOOK_URL, { text });
  }
}

module.exports = { postDigest };
