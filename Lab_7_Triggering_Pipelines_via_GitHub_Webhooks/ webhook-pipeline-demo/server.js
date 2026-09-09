const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Webhook Pipeline Demo - Updated!',
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    features: ['webhooks', 'auto-deployment', 'continuous-integration']
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

app.get('/version', (req, res) => {
  res.json({
    version: '2.0.0',
    buildTime: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
  console.log('New features added: /version endpoint');
});
