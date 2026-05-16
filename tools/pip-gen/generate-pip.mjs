#!/usr/bin/env node
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = resolve(__dirname, '../..');
const KEY_PATH = resolve(PROJECT_ROOT, 'settle_this/.env.local.txt');
const OUT_DIR = resolve(PROJECT_ROOT, 'settle_this/assets/pip/_recraft_drafts');

const RECRAFT_ENDPOINT = 'https://external.api.recraft.ai/v1/images/generations';

const POSES = {
  triumph: {
    label: 'Pip Triumphant',
    prompt: [
      'Plush stout owl mascot. Deep navy judge robe with cream Peter Pan collar.',
      'Holding an oversized golden gavel mid-swing in one wing. One eye in a confident wink, small smirk, head tilted. Confident judge-in-command pose.',
      'Round symmetrical eyes, navy iris on cream sclera, small white highlight. Small golden triangular beak. Soft coral cheek blush.',
      'Body ratio 1:1 head-to-body, dome head into oval body. Robe trapezoid conceals the feet.',
      'Flat vector style, solid color fill, no outlines, no shading, no gradients, no painterly texture, no realistic feathers. Soft rounded shapes. Duolingo-meets-Headspace vibe.',
      'Palette: cream #FBF6EC, navy #1F2452, gold #E8B43C, coral #EF6F5E. No other colors.',
      'Transparent background. Single centered character. No text.',
    ].join(' '),
  },
  listening: {
    label: 'Pip Listening',
    prompt: [
      'Cute illustrated owl mascot named Pip, warm brown plumage, deep navy judge robe with cream Peter Pan collar and small gold clasp. Standing on flat ground.',
      'POSE: Both wings folded across the chest and belly like crossed arms. Wings NEVER raised. Wings NEVER above shoulders. Wings do NOT touch the gavel.',
      'GAVEL: A gold gavel with wooden handle lies flat on the ground in front of Pip\'s feet, resting horizontally on a small wood block. Gavel is set DOWN, never held, never raised.',
      'Calm empathetic expression, soft eyebrows, head tilted slightly, both eyes open same size, no wink, closed beak, coral cheek blushes.',
      'Children\'s book illustration style, soft outlines, gentle painted shading. Same character as Pip Triumphant. CALM listening variant, NOT a confident triumph pose.',
      'Transparent background. Single character with gavel on ground in front. No text. No books. No props beyond gavel and wood block.',
    ].join(' '),
  },
};

async function loadApiKey() {
  const raw = await readFile(KEY_PATH, 'utf8');
  // Support either "RECRAFT_API_KEY=xxx" or a bare key on a single line.
  const cleaned = raw.split('\n').map((l) => l.trim()).filter(Boolean);
  for (const line of cleaned) {
    if (line.startsWith('#')) continue;
    if (line.includes('=')) {
      const [k, v] = line.split('=', 2);
      if (k.trim() === 'RECRAFT_API_KEY') return v.trim().replace(/^["']|["']$/g, '');
    } else {
      return line;
    }
  }
  throw new Error(`No API key found in ${KEY_PATH}`);
}

async function generate({ apiKey, prompt, style, substyle, n, size }) {
  const body = {
    prompt,
    style,
    n,
    size,
    response_format: 'url',
  };
  if (substyle) body.substyle = substyle;

  const res = await fetch(RECRAFT_ENDPOINT, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  const text = await res.text();
  if (!res.ok) {
    throw new Error(`Recraft API ${res.status}: ${text}`);
  }
  return JSON.parse(text);
}

const CONTENT_TYPE_EXT = {
  'image/png': 'png',
  'image/svg+xml': 'svg',
  'image/jpeg': 'jpg',
  'image/webp': 'webp',
};

async function downloadImage(url, basePath) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Download failed ${res.status} ${url}`);
  const ct = (res.headers.get('content-type') || '').split(';')[0].trim().toLowerCase();
  const ext = CONTENT_TYPE_EXT[ct] || ct.split('/')[1] || 'bin';
  const buf = Buffer.from(await res.arrayBuffer());
  const outPath = `${basePath}.${ext}`;
  await writeFile(outPath, buf);
  return outPath;
}

function parseArgs(argv) {
  const args = { pose: 'triumph', n: 1, style: 'digital_illustration', substyle: null, size: '1024x1024' };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--pose') args.pose = argv[++i];
    else if (a === '-n' || a === '--n') args.n = parseInt(argv[++i], 10);
    else if (a === '--style') args.style = argv[++i];
    else if (a === '--substyle') args.substyle = argv[++i] === 'none' ? null : argv[++i];
    else if (a === '--size') args.size = argv[++i];
    else if (a === '--help' || a === '-h') {
      console.log(`Usage: node generate-pip.mjs [--pose triumph|listening|both] [-n 1..6] [--style vector_illustration|digital_illustration] [--substyle flat_2|none] [--size 1024x1024]`);
      process.exit(0);
    }
  }
  return args;
}

async function run() {
  const args = parseArgs(process.argv.slice(2));
  const apiKey = await loadApiKey();
  await mkdir(OUT_DIR, { recursive: true });

  const poses = args.pose === 'both' ? ['triumph', 'listening'] : [args.pose];
  const ts = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);

  for (const poseKey of poses) {
    const cfg = POSES[poseKey];
    if (!cfg) {
      console.error(`Unknown pose: ${poseKey}. Use triumph, listening, or both.`);
      process.exit(1);
    }
    console.log(`\n→ Generating ${args.n}x ${cfg.label} (style=${args.style}${args.substyle ? `, substyle=${args.substyle}` : ''}, size=${args.size})`);
    const result = await generate({
      apiKey,
      prompt: cfg.prompt,
      style: args.style,
      substyle: args.substyle,
      n: args.n,
      size: args.size,
    });

    const items = result.data || [];
    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      const url = item.url;
      if (!url) {
        console.warn(`  [${i + 1}] no url in response item, skipping`);
        continue;
      }
      const baseName = `${poseKey}_${ts}_${i + 1}`;
      const basePath = resolve(OUT_DIR, baseName);
      const savedPath = await downloadImage(url, basePath);
      console.log(`  [${i + 1}] saved → ${savedPath}`);
    }

    if (result.credits) {
      console.log(`  credits used this call: ${result.credits}`);
    }
  }
  console.log(`\nDone. Drafts in: ${OUT_DIR}`);
}

run().catch((err) => {
  console.error('\n✖ Error:', err.message);
  process.exit(1);
});
