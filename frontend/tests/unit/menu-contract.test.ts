import { describe, expect, it } from 'vitest'

import {
  buildDictionaryBlock,
  buildPrompt,
  parseMenuResponse,
  type ParsedMenu
} from '#menu-contract'

const dictionary = [
  { slug: 'pho-bo', name_vi: 'Phở bò' },
  { slug: 'com-ga', name_vi: 'Cơm gà' }
]

const usableResponse = {
  sections: [
    {
      title_vi: 'Món chính',
      items: [
        {
          raw_vi: 'Phở bò',
          price_vnd: 50000,
          dish_slug: 'pho-bo',
          ai_name_ru: 'Фо бо',
          ai_name_en: 'Pho bo',
          ai_summary_ru: 'Суп с говядиной.',
          ai_summary_en: 'Beef noodle soup.',
          confidence: 92
        },
        {
          raw_vi: 'Cà phê sữa đá',
          price_vnd: '25000',
          dish_slug: 'not-in-dictionary',
          ai_name_ru: 'Кофе со сгущёнкой',
          ai_name_en: 'Iced milk coffee',
          ai_summary_ru: 'Кофе со льдом.',
          ai_summary_en: 'Coffee with ice.',
          confidence: 70
        },
        { raw_vi: '   ', price_vnd: null, confidence: 10 },
        { price_vnd: 5 },
        'garbage'
      ]
    },
    { title_vi: 'Пустая секция', items: [{ raw_vi: '', confidence: 5 }] },
    'not-a-section'
  ]
}

describe('buildPrompt', () => {
  it('includes every dictionary line as slug|name_vi', () => {
    const prompt = buildPrompt(dictionary)
    expect(prompt).toContain('pho-bo|Phở bò')
    expect(prompt).toContain('com-ga|Cơm gà')
  })

  it('bans invented slugs and demands strict JSON', () => {
    const prompt = buildPrompt(dictionary)
    expect(prompt).toContain('MUST be null. Never invent slugs.')
    expect(prompt).toContain('STRICT JSON only')
  })
})

describe('buildDictionaryBlock', () => {
  it('joins entries pipe-joined one per line', () => {
    expect(buildDictionaryBlock(dictionary)).toBe('pho-bo|Phở bò\ncom-ga|Cơm gà')
  })
})

describe('parseMenuResponse', () => {
  const allowed = dictionary.map(dish => dish.slug)

  it('sanitizes items: drops empty/non-object entries, coerces types', () => {
    const menu: ParsedMenu = parseMenuResponse(JSON.stringify(usableResponse), allowed)
    expect(menu.sections).toHaveLength(1)
    const items = menu.sections[0].items
    expect(items).toHaveLength(2)
    expect(items[0]).toMatchObject({
      raw_vi: 'Phở bò',
      price_vnd: 50000,
      dish_slug: 'pho-bo',
      confidence: 92
    })
    // String price is coerced to a number; slug outside the dictionary is nulled.
    expect(items[1].price_vnd).toBe(25000)
    expect(items[1].dish_slug).toBeNull()
  })

  it('keeps dictionary slugs only when an allowlist is given', () => {
    const menu = parseMenuResponse(JSON.stringify(usableResponse))
    const withUnknownSlug = menu.sections[0].items[1]
    expect(withUnknownSlug.dish_slug).toBe('not-in-dictionary')
  })

  it('clamps confidence into 0..100 and defaults missing section title', () => {
    const menu = parseMenuResponse(JSON.stringify({
      sections: [{ items: [{ raw_vi: 'X', confidence: 999 }] }]
    }))
    expect(menu.sections[0].title_vi).toBe('Menu')
    expect(menu.sections[0].items[0].confidence).toBe(100)
  })

  it('accepts a fenced response and a bare sections array', () => {
    const body = JSON.stringify(usableResponse)
    expect(parseMenuResponse('```json\n' + body + '\n```', allowed).sections).toHaveLength(1)
    expect(parseMenuResponse(JSON.stringify(usableResponse.sections), allowed).sections).toHaveLength(1)
  })

  it('rejects structurally unusable output', () => {
    expect(() => parseMenuResponse('not json')).toThrow()
    expect(() => parseMenuResponse('{"sections":[]}', allowed)).toThrow('no usable items')
    expect(() => parseMenuResponse('{"foo":1}', allowed)).toThrow()
  })
})
