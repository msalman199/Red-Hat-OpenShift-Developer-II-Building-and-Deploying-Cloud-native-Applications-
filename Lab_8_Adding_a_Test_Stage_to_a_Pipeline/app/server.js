const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/api/status', (req, res) => {
  res.status(200).json({ 
    message: 'Application is healthy',
    version: '1.0.0',
    uptime: process.uptime()
  });
});

app.get('/', (req, res) => {
  res.send('Hello from Pipeline Test Application!');
});

const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

module.exports = { app, server };
