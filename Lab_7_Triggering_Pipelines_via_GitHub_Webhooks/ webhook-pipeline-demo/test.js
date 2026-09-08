const http = require('http');

const options = {
  hostname: 'localhost',
  port: 8080,
  path: '/',
  method: 'GET'
};

const req = http.request(options, (res) => {
  console.log(`statusCode: ${res.statusCode}`);
  
  res.on('data', (d) => {
    const data = JSON.parse(d);
    console.log('Response:', data);
    
    if (data.version === '2.0.0') {
      console.log('✅ Test passed: Version updated correctly');
    } else {
      console.log('❌ Test failed: Version not updated');
    }
  });
});

req.on('error', (error) => {
  console.error('Test failed:', error);
});

req.end();
