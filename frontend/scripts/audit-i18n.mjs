import { readFileSync, readdirSync, statSync } from 'node:fs'
import { join } from 'node:path'

const localesDir = join(process.cwd(), 'i18n/locales')
const appDir = join(process.cwd(), 'app')

const flatten = (obj, prefix = '') =>
  Object.entries(obj).flatMap(([k, v]) =>
    typeof v === 'object' && v !== null ? flatten(v, `${prefix}${k}.`) : [`${prefix}${k}`]
  )

const ru = flatten(JSON.parse(readFileSync(join(localesDir, 'ru.json'), 'utf8')))
const en = flatten(JSON.parse(readFileSync(join(localesDir, 'en.json'), 'utf8')))

const ruSet = new Set(ru)
const enSet = new Set(en)
const onlyRu = ru.filter(k => !enSet.has(k))
const onlyEn = en.filter(k => !ruSet.has(k))
console.log('KEY PARITY')
console.log('  only in ru:', onlyRu.length ? onlyRu : 'none')
console.log('  only in en:', onlyEn.length ? onlyEn : 'none')

// collect all source text
const sources = []
const walk = (dir) => {
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry)
    if (statSync(p).isDirectory()) walk(p)
    else if (/\.(vue|ts)$/.test(entry)) sources.push(readFileSync(p, 'utf8'))
  }
}
walk(appDir)
const all = sources.join('\n')

// a key is used if it appears literally, or its parent appears with dynamic children
const used = new Set()
for (const key of ruSet) {
  if (all.includes(`'${key}'`) || all.includes(`"${key}"`) || all.includes(`\`${key}\``) || all.includes(`'${key}.`) || all.includes(`"${key}.`) || all.includes(`\`${key}.`)) {
    used.add(key)
    continue
  }
  // dynamic parent check: e.g. t(`food.filters.${item.type}`) -> parent key 'food.filters'
  const parts = key.split('.')
  for (let i = parts.length - 1; i > 0; i--) {
    const parent = parts.slice(0, i).join('.')
    if (all.includes(`\`${parent}.` + '${') || all.includes(`'${parent}.` + '\' +') || all.includes(`"${parent}.` + '" +') || all.includes(parent + '.${')) {
      used.add(key)
      break
    }
  }
}
// template t('...') with concatenation via +
const unused = ru.filter(k => !used.has(k) && !onlyRu.includes(k))
console.log('\nPOSSIBLY UNUSED KEYS (ru):')
console.log(unused.length ? unused.map(k => '  ' + k).join('\n') : '  none')
