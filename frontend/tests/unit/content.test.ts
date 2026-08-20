import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'

import { describe, expect, it } from 'vitest'

import { mockDb } from '../../app/mocks/db'
import { housingGuideData } from '../../app/mocks/housing'

const flatten = (obj: Record<string, unknown>, prefix = ''): string[] =>
  Object.entries(obj).flatMap(([key, value]) =>
    typeof value === 'object' && value !== null
      ? flatten(value as Record<string, unknown>, `${prefix}${key}.`)
      : [`${prefix}${key}`]
  )

const loadLocale = (file: string) =>
  JSON.parse(readFileSync(resolve(__dirname, '../../i18n/locales', file), 'utf8')) as Record<string, unknown>

describe('locale files', () => {
  it('ru and en expose the exact same key set', () => {
    const ru = new Set(flatten(loadLocale('ru.json')))
    const en = new Set(flatten(loadLocale('en.json')))
    expect([...ru].filter(key => !en.has(key))).toEqual([])
    expect([...en].filter(key => !ru.has(key))).toEqual([])
  })

  it('has no empty translation strings', () => {
    const leaves = (obj: Record<string, unknown>): unknown[] =>
      Object.values(obj).flatMap(value =>
        typeof value === 'object' && value !== null ? leaves(value as Record<string, unknown>) : [value]
      )
    for (const file of ['ru.json', 'en.json']) {
      for (const value of leaves(loadLocale(file))) {
        expect(typeof value === 'string' && value.trim() === '', `${file} has an empty string`).toBe(false)
      }
    }
  })
})

describe('mock db integrity', () => {
  it('uses unique ids per collection', () => {
    const collections = {
      cities: mockDb.cities,
      categories: mockDb.categories,
      places: mockDb.places,
      guides: mockDb.guides,
      contacts: mockDb.contacts,
      reviews: mockDb.reviews,
      activity: mockDb.activity
    }
    for (const [name, items] of Object.entries(collections)) {
      const ids = items.map(item => item.id)
      expect(new Set(ids).size, `${name} ids must be unique`).toBe(ids.length)
    }
  })

  it('only references reviews to known places', () => {
    const placeIds = new Set(mockDb.places.map(place => place.id))
    for (const review of mockDb.reviews) {
      expect(placeIds.has(review.placeId), `review ${review.id} points to unknown place ${review.placeId}`).toBe(true)
    }
  })

  it('keeps review ratings between 1 and 5', () => {
    for (const review of mockDb.reviews) {
      expect(review.rating).toBeGreaterThanOrEqual(1)
      expect(review.rating).toBeLessThanOrEqual(5)
    }
  })
})

describe('housing district content', () => {
  const ru = loadLocale('ru.json') as Record<string, never>
  const en = loadLocale('en.json') as Record<string, never>
  const lookup = (locale: Record<string, never>, key: string) =>
    key.split('.').reduce<unknown>((node, part) => (node as Record<string, unknown>)?.[part], locale)

  it('resolves every district i18n key in both locales', () => {
    for (const feature of housingGuideData.districts.features) {
      const props = feature.properties
      const keys = [props.label, props.area, props.distanceToBeach, props.rentRange, props.priceRange, props.summary, ...props.bestFor]
      for (const key of keys) {
        expect(lookup(ru, key), `ru missing ${key}`).toBeTruthy()
        expect(lookup(en, key), `en missing ${key}`).toBeTruthy()
      }
    }
  })

  it('has closed polygon rings with lon/lat pairs', () => {
    for (const feature of housingGuideData.districts.features) {
      const ring = feature.geometry.coordinates[0] ?? []
      expect(ring.length).toBeGreaterThanOrEqual(4)
      const [firstLon, firstLat] = ring[0]
      const [lastLon, lastLat] = ring[ring.length - 1]
      expect([lastLon, lastLat]).toEqual([firstLon, firstLat])
      for (const [lon, lat] of ring) {
        expect(lon).toBeGreaterThan(107)
        expect(lon).toBeLessThan(110)
        expect(lat).toBeGreaterThan(15)
        expect(lat).toBeLessThan(17)
      }
    }
  })

  it('has unique housing resources with valid https urls', () => {
    const ids = housingGuideData.resources.map(resource => resource.id)
    expect(new Set(ids).size).toBe(ids.length)
    for (const resource of housingGuideData.resources) {
      expect(resource.url.startsWith('https://'), `${resource.id} must use https`).toBe(true)
      expect(resource.name.trim().length).toBeGreaterThan(0)
    }
  })

  it('resolves every section i18n key in both locales', () => {
    for (const section of housingGuideData.sections) {
      const keys = [section.title, section.description, ...section.bullets]
      for (const key of keys) {
        expect(lookup(ru, key), `ru missing ${key}`).toBeTruthy()
        expect(lookup(en, key), `en missing ${key}`).toBeTruthy()
      }
    }
  })
})
