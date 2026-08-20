import { mockDb } from '~/mocks/db'
import type { ReviewStatus } from '~/types/content'

export function useMockDb() {
  const db = useState('mock-db', () => structuredClone(mockDb))

  function togglePlaceStatus(id: string) {
    const place = db.value.places.find(item => item.id === id)
    if (place) place.status = place.status === 'published' ? 'draft' : 'published'
  }

  function toggleCityActive(id: string) {
    const city = db.value.cities.find(item => item.id === id)
    if (city) city.active = !city.active
  }

  function toggleGuideStatus(id: string) {
    const guide = db.value.guides.find(item => item.id === id)
    if (guide) guide.status = guide.status === 'published' ? 'draft' : 'published'
  }

  function setReviewStatus(id: string, status: ReviewStatus) {
    const review = db.value.reviews.find(item => item.id === id)
    if (review) review.status = status
  }

  return {
    db,
    togglePlaceStatus,
    toggleCityActive,
    toggleGuideStatus,
    setReviewStatus
  }
}
