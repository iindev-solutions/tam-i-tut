import { ref, shallowRef } from 'vue'

/**
 * Dish photo gallery: live Wikimedia Commons search by dish name, cached in
 * sessionStorage for the app session (no API key, Commons sends permissive
 * CORS headers). Returns up to `limit` thumbnail URLs; empty array = nothing
 * found (the curated photo above stays the only image).
 */

interface CommonsPage {
  title?: string
  imageinfo?: Array<{ thumburl?: string, mime?: string }>
}

const MAX_SIDE = 640

const cache = (key: string): string[] | null => {
  try {
    const raw = sessionStorage.getItem(`dish-gallery:${key}`)
    return raw ? (JSON.parse(raw) as string[]) : null
  } catch {
    return null
  }
}

const store = (key: string, urls: string[]) => {
  try {
    sessionStorage.setItem(`dish-gallery:${key}`, JSON.stringify(urls))
  } catch {
    // Private mode / quota: gallery just refetches next time.
  }
}

async function commonsSearch(query: string, limit: number): Promise<string[]> {
  const url = new URL('https://commons.wikimedia.org/w/api.php')
  url.searchParams.set('action', 'query')
  url.searchParams.set('generator', 'search')
  url.searchParams.set('gsrsearch', query)
  url.searchParams.set('gsrnamespace', '6')
  url.searchParams.set('gsrlimit', String(limit * 2))
  url.searchParams.set('prop', 'imageinfo')
  url.searchParams.set('iiprop', 'url|mime')
  url.searchParams.set('iiurlwidth', String(MAX_SIDE))
  url.searchParams.set('format', 'json')
  url.searchParams.set('origin', '*')

  const response = await fetch(url.toString(), { headers: { Accept: 'application/json' } })
  if (!response.ok) return []
  const data = await response.json() as { query?: { pages?: Record<string, CommonsPage> } }
  const pages = Object.values(data.query?.pages ?? {})
  const urls: string[] = []
  for (const page of pages) {
    const info = page.imageinfo?.[0]
    const thumb = info?.thumburl
    if (thumb && (info?.mime === 'image/jpeg' || info?.mime === 'image/png')) {
      urls.push(thumb)
    }
    if (urls.length >= limit) break
  }
  return urls
}

export function useDishGallery() {
  const gallery = shallowRef<string[]>([])
  const loading = ref(false)
  let requestSeq = 0

  async function load(nameVi: string, nameEn: string, excludeUrl: string | null): Promise<void> {
    const key = nameVi || nameEn
    if (!key) {
      gallery.value = []
      return
    }
    const cached = cache(key)
    if (cached) {
      gallery.value = cached
      return
    }
    gallery.value = []
    loading.value = true
    const seq = ++requestSeq
    try {
      // Commons indexes Vietnamese titles well, but English widens coverage.
      let urls = await commonsSearch(`${nameVi} Vietnam`, 6)
      if (urls.length < 3) {
        const more = await commonsSearch(nameEn || nameVi, 6)
        urls = [...new Set([...urls, ...more])]
      }
      urls = urls.filter(url => url !== excludeUrl).slice(0, 6)
      if (seq === requestSeq) {
        gallery.value = urls
        if (urls.length > 0) store(key, urls)
      }
    } catch {
      if (seq === requestSeq) gallery.value = []
    } finally {
      if (seq === requestSeq) loading.value = false
    }
  }

  function reset() {
    requestSeq++
    gallery.value = []
    loading.value = false
  }

  return { gallery, loading, load, reset }
}
