#!/usr/bin/env node

/**
 * Simple HTTP proxy to forward requests from Mac's IP to DDEV localhost
 * This allows iOS simulator to reach DDEV via the Mac's IP address
 * 
 * Usage: node scripts/ddev-proxy.js [port]
 * Default port: 55038 (DDEV HTTP port)
 */

const http = require('http');
const { execSync } = require('child_process');

const DDEV_PORT = process.argv[2] || '55038';
const PROXY_PORT = 8888; // Port that simulator will connect to

// Get Mac's IP address
function getLocalIP() {
  try {
    const output = execSync("ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | head -1", {
      encoding: 'utf-8'
    }).trim();
    return output || '192.168.0.106'; // Fallback
  } catch (e) {
    return '192.168.0.106'; // Fallback
  }
}

const localIP = getLocalIP();

const server = http.createServer((req, res) => {
  console.log(`[PROXY] ${req.method} ${req.url} from ${req.socket.remoteAddress}`);
  
  const options = {
    hostname: '127.0.0.1',
    port: DDEV_PORT,
    path: req.url,
    method: req.method,
    headers: {
      ...req.headers,
      host: `127.0.0.1:${DDEV_PORT}`, // Override host header
    }
  };

  const proxyReq = http.request(options, (proxyRes) => {
    // Add CORS headers for React Native
    const headers = { ...proxyRes.headers };
    headers['Access-Control-Allow-Origin'] = '*';
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
      headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-API-Key';
    
    res.writeHead(proxyRes.statusCode, headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    console.error('Proxy error:', err);
    res.writeHead(500);
    res.end('Proxy error: ' + err.message);
  });

  req.pipe(proxyReq);
});

server.listen(PROXY_PORT, '0.0.0.0', () => {
  console.log(`DDEV Proxy running on http://${localIP}:${PROXY_PORT}`);
  console.log(`Forwarding to http://127.0.0.1:${DDEV_PORT}`);
  console.log(`Update config.ts to use: http://${localIP}:${PROXY_PORT}`);
});

