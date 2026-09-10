const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
const environment = process.env.NODE_ENV || 'development';
const version = process.env.APP_VERSION || '1.0.0';

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Multi-Environment CI/CD',
    environment: environment,
    version: version
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', environment: environment });
});

app.listen(port, () => {
  console.log(`App running on port ${port} in ${environment} environment`);
});
