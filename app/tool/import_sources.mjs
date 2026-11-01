import fs from 'node:fs';
import crypto from 'node:crypto';

const args = Object.fromEntries(
  process.argv.slice(2).reduce((result, value, index, values) => {
    if (value.startsWith('--')) result.push([value.slice(2), values[index + 1]]);
    return result;
  }, []),
);

function read(path) {
  return fs.readFileSync(path, 'utf8');
}

function pipeRows(path) {
  return read(path).split(/\r?\n/).flatMap((line) => {
    const match = line.match(/^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*(?:\|\s*([^|]+?)\s*)?\|/);
    if (!match || /^-+$/.test(match[1].trim())) return [];
    if (['kanji', 'kosakata'].includes(match[1].trim().toLowerCase())) return [];
    return [[match[1].trim(), match[2].trim(), match[3]?.trim() ?? '']];
  });
}

function n3Kanji(path) {
  return read(path).split(/\r?\n/).flatMap((line) => {
    const match = line.match(/^###\s+(.+?)\s+—\s+(.+?)\s+—\s+(.+?)(?:\s+_.*)?$/);
    if (!match || match[1].length > 4) return [];
    return [[match[1].trim(), match[2].trim(), match[3].trim()]];
  });
}

function n3Words(path) {
  return read(path).split(/\r?\n/).flatMap((line) => {
    const match = line.match(/^\s*-\s+(.+?)\s+---\s+(.+?)\s+---\s+(.+?)\s*$/);
    return match ? [[match[1].trim(), match[2].trim(), match[3].trim()]] : [];
  });
}

function makeCard(id, category, level, front, reading, meaning, order) {
  return { id, category, level, front, reading, romaji: '', meaning, example: '', order };
}

const output = args.output;
const cards = JSON.parse(fs.readFileSync(output, 'utf8'))
  .filter((card) => !card.id.startsWith('kanji-n4-source-')
    && !card.id.startsWith('kotoba-n4-source-')
    && !card.id.startsWith('kanji-n3-source-')
    && !card.id.startsWith('kotoba-n3-source-'));
const ids = new Set(cards.map((card) => card.id));
function stableId(category, level, front, reading) {
  const key = `${category}|${level}|${front}|${reading}`;
  return `source-${crypto.createHash('sha1').update(key).digest('hex').slice(0, 12)}`;
}

function add(card) {
  if (!ids.has(card.id)) {
    ids.add(card.id);
    cards.push(card);
  }
}

pipeRows(args['kanji-n4']).forEach(([front, reading, meaning], index) => {
  add(makeCard(
    stableId('kanji', 'n4', front, reading),
    'kanji', 'n4', front, reading, meaning, index + 1,
  ));
});

pipeRows(args['kotoba-n4']).forEach(([front, meaning], index) => {
  const reading = front.match(/\(([^)]+)\)/)?.[1] ?? front;
  add(makeCard(
    stableId('kotoba', 'n4', front, reading),
    'kotoba', 'n4', front, reading, meaning, index + 1,
  ));
});

n3Kanji(args.n3).forEach(([front, reading, meaning], index) => {
  add(makeCard(
    stableId('kanji', 'n3', front, reading),
    'kanji', 'n3', front, reading, meaning, index + 1,
  ));
});

n3Words(args.n3).forEach(([front, reading, meaning], index) => {
  add(makeCard(
    stableId('kotoba', 'n3', front, reading),
    'kotoba', 'n3', front, reading, meaning, index + 1,
  ));
});

fs.writeFileSync(output, `${JSON.stringify(cards, null, 2)}\n`, 'utf8');
console.log(`wrote ${cards.length} cards to ${output}`);
