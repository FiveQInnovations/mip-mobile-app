#!/usr/bin/env node
/**
 * Generate PWA icons (PNG format) from SVG template
 * Creates 192x192 and 512x512 PNG icons for PWA manifest
 */

import { writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import sharp from 'sharp';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');
const iconsDir = join(rootDir, 'public', 'icons');

// Create icon SVG template
const createIconSVG = (size) => {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}">
  <rect width="${size}" height="${size}" fill="#2563eb"/>
  <text x="50%" y="50%" font-family="Arial, sans-serif" font-size="${size * 0.3}" fill="white" text-anchor="middle" dominant-baseline="middle">M</text>
</svg>`;
};

async function generateIcons() {
  try {
    const sizes = [192, 512];
    
    for (const size of sizes) {
      const svg = createIconSVG(size);
      const pngBuffer = await sharp(Buffer.from(svg))
        .resize(size, size)
        .png()
        .toBuffer();
      
      writeFileSync(join(iconsDir, `icon-${size}.png`), pngBuffer);
      console.log(`✅ Generated icon-${size}.png`);
    }
    
    console.log('✅ All PWA icons generated successfully');
  } catch (error) {
    console.error('❌ Error generating icons:', error);
    process.exit(1);
  }
}

generateIcons();
