const http = require('node:http');

const server = http.createServer((req, res) => {
  if (req.url === '/healthz') {
    res.writeHead(200, { 'content-type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  res.writeHead(200, { 'content-type': 'application/json' });
  res.end(JSON.stringify({
    message: 'request accepted by the authenticated edge',
    client: req.headers['x-client-subject'] || 'missing',
    verification: req.headers['x-client-verify'] || 'missing'
  }));
});

server.listen(8080, '0.0.0.0', () => {
  console.log(JSON.stringify({ event: 'upstream_started', port: 8080 }));
});

