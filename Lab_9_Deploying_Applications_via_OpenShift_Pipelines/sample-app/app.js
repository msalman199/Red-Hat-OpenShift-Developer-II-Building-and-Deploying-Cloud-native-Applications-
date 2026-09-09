const express = require('express');
const app = express();
const port = 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from OpenShift Pipeline Deployment!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(\`App listening at http://localhost:\${port}\`);
});
