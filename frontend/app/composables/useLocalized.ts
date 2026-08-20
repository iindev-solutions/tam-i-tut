import { useI18n } from 'vue-i18n'

import type { LocalizedText } from '~/types/content'

export function useLocalized() {
  const { locale } = useI18n()

  const tt = (text: LocalizedText) => text[locale.value]

  return { tt }
}
