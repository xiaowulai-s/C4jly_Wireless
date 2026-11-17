// _gen_icon.js - generate a minimal valid 32x32 icon.ico (solid teal + white dot)
const fs = require('fs');
const path = require('path');
const dir = 'D:/Demo/C4JianLouYi/C4F7N_Wireless/pc/src-tauri/icons';
fs.mkdirSync(dir, { recursive: true });

const W = 32, H = 32;
// BGRA bottom-up pixel data
const px = Buffer.alloc(W * H * 4);
for (let y = 0; y < H; y++) {
  for (let x = 0; x < W; x++) {
    const i = (y * W + x) * 4;
    const cx = x - 15.5, cy = y - 15.5;
    const dist = Math.sqrt(cx * cx + cy * cy);
    let r = 0x0f, g = 0x6e, b = 0x56; // teal #0F6E56
    if (dist > 14) { r = g = b = 0x22; }
    if (dist < 6) { r = 0xFF; g = 0xFF; b = 0xFF; } // center dot
    px[i] = b; px[i + 1] = g; px[i + 2] = r; px[i + 3] = 0xFF;
  }
}
const andMask = Buffer.alloc(W * H / 8);
const bmpHeader = Buffer.alloc(40);
bmpHeader.writeUInt32LE(40, 0);
bmpHeader.writeInt32LE(W, 4);
bmpHeader.writeInt32LE(H * 2, 8); // XOR + AND
bmpHeader.writeUInt16LE(1, 12);
bmpHeader.writeUInt16LE(32, 14);

const img = Buffer.concat([bmpHeader, px, andMask]);
const header = Buffer.alloc(6);
header.writeUInt16LE(0, 0);
header.writeUInt16LE(1, 2);
header.writeUInt16LE(1, 4);
const entry = Buffer.alloc(16);
entry[0] = W; entry[1] = H;
entry[2] = 0; entry[3] = 0;
entry.writeUInt16LE(1, 4);
entry.writeUInt16LE(32, 6);
entry.writeUInt32LE(img.length, 8);
entry.writeUInt32LE(6 + 16, 12);

fs.writeFileSync(path.join(dir, 'icon.ico'), Buffer.concat([header, entry, img]));
console.log('icon.ico written', 6 + 16 + img.length, 'bytes');
