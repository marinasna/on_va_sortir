const http = require('http');

const data = JSON.stringify({
  identity: 'admin@admin.com',
  password: 'admin1234'
});

const req = http.request({
  hostname: '127.0.0.1',
  port: 8090,
  path: '/api/admins/auth-with-password',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
}, (res) => {
  let body = '';
  res.on('data', d => body += d);
    const parsed = JSON.parse(body);
    const token = parsed.token;
    
    if (!token) {
      console.error("No token!", body);
      return;
    }

    // Update collection
    const updateData = JSON.stringify({
      createRule: "@request.auth.id != ''"
    });
    
    const patchReq = http.request({
      hostname: '127.0.0.1',
      port: 8090,
      path: '/api/collections/notifications',
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token,
        'Content-Length': Buffer.byteLength(updateData)
      }
    }, (patchRes) => {
      let pb = '';
      patchRes.on('data', d => pb += d);
      patchRes.on('end', () => console.log('Updated:', pb));
    });
    
    patchReq.write(updateData);
    patchReq.end();
  });
});

req.write(data);
req.end();
