const http = require('http');

async function request(options, data) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', d => body += d);
      res.on('end', () => resolve({ statusCode: res.statusCode, body: JSON.parse(body || '{}') }));
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

async function main() {
  try {
    // 1. Auth Admin
    const authData = JSON.stringify({ identity: 'admin@admin.com', password: 'admin1234' });
    const auth = await request({
      hostname: '127.0.0.1', port: 8090, path: '/api/collections/_pb_admins_auth_/auth-with-password', method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': authData.length }
    }, authData);

    const token = auth.body.token;
    if (!token) throw new Error('No token: ' + JSON.stringify(auth.body));

    // 2. Fetch notifications collection
    const notifCol = await request({
      hostname: '127.0.0.1', port: 8090, path: '/api/collections/notifications', method: 'GET',
      headers: { 'Authorization': 'Bearer ' + token }
    });

    // 3. Update createRule
    const updateNotif = JSON.stringify({ createRule: "@request.auth.id != ''" });
    await request({
      hostname: '127.0.0.1', port: 8090, path: '/api/collections/notifications', method: 'PATCH',
      headers: { 'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json', 'Content-Length': updateNotif.length }
    }, updateNotif);

    console.log('Notifications rule updated!');

    // 4. Fetch events collection
    const eventsCol = await request({
      hostname: '127.0.0.1', port: 8090, path: '/api/collections/events', method: 'GET',
      headers: { 'Authorization': 'Bearer ' + token }
    });

    // 5. Add creator field if not exists
    if (!eventsCol.body.fields.some(f => f.name === 'creator')) {
      const newFields = [...eventsCol.body.fields, {
        "hidden": false,
        "id": "rel_event_creator",
        "name": "creator",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation",
        "relationOptions": {
          "collectionId": "_pb_users_auth_",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": null
        }
      }];
      const updateEvent = JSON.stringify({ fields: newFields });
      await request({
        hostname: '127.0.0.1', port: 8090, path: '/api/collections/events', method: 'PATCH',
        headers: { 'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json', 'Content-Length': updateEvent.length }
      }, updateEvent);
      console.log('Events creator field added!');
    }

  } catch (e) {
    console.error('Error:', e.message);
  }
}

main();
