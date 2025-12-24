#!/usr/bin/env node

/**
 * Helper script to get the DDEV HTTP port for the ws-ffci-copy project
 * This can be used to update the config.ts file automatically
 */

const { execSync } = require('child_process');

try {
  const ddevDescribe = execSync('cd ../sites/ws-ffci-copy && ddev describe', {
    encoding: 'utf-8',
    stdio: 'pipe',
  });

  // Parse the output to find the HTTP port
  // Format: " - web:80 -> 127.0.0.1:55038"
  const portMatch = ddevDescribe.match(/web:80\s+->\s+127\.0\.0\.1:(\d+)/);
  
  if (portMatch && portMatch[1]) {
    console.log(portMatch[1]);
    process.exit(0);
  } else {
    console.error('Could not find DDEV HTTP port');
    process.exit(1);
  }
} catch (error) {
  console.error('Error running ddev describe:', error.message);
  process.exit(1);
}

