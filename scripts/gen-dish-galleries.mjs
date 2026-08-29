import fs from 'node:fs'

// Generates migration 041 (gallery_urls column + updates) and mirrors the
// update statements into seed.sql. Run once; 041 is applied to hosted via db push.
const galleries = JSON.parse(fs.readFileSync('scripts/dish-galleries.json', 'utf8'))

const esc = s => s.replace(/'/g, "''")
const arrLit = urls => `'{${urls.map(u => esc(u).replace(/,/g, '\\,')).join(',')}}'`

let updates = ''
const missing = []
for (const [slug, urls] of Object.entries(galleries)) {
  if (!Array.isArray(urls) || urls.length === 0) {
    missing.push(slug)
    continue
  }
  updates += `update public.dishes set gallery_urls = ${arrLit(urls)} where slug = '${slug}';\n`
}

const migration = `-- Migration: 041_dish_galleries
-- Purpose: curated photo galleries for the dish dictionary (3-5 verified
-- Wikimedia Commons shots per dish, agent-sourced and hotlink-checked).
-- Rendered under the description on dish cards ("How it looks").
-- Mirrored into seed.sql via the update-statement block.

alter table public.dishes add column if not exists gallery_urls text[] not null default '{}';

${updates}`

fs.writeFileSync('supabase/migrations/20260830120000_041_dish_galleries.sql', migration)

// seed.sql mirror block
let seed = fs.readFileSync('supabase/seed.sql', 'utf8')
const begin = '-- BEGIN dish gallery mirror'
const end = '-- END dish gallery mirror'
const block = `${begin}\nalter table public.dishes add column if not exists gallery_urls text[] not null default '{}';\n${updates}${end}\n`
seed = seed.replace(new RegExp(begin + '[\\s\\S]*?' + end + '\\n?', 'g'), '').trimEnd()
fs.writeFileSync('supabase/seed.sql', seed + '\n\n' + block)

console.log('migration 041 written | dishes:', Object.keys(galleries).length, '| updates:', Object.keys(galleries).length - missing.length, '| missing:', missing.join(',') || 'none')
