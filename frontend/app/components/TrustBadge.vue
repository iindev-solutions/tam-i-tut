<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

import type { TrustLevel } from '~/types/content'

interface Props {
  level: TrustLevel
  /** ISO timestamp of the team's last check; null while under review. */
  verifiedAt?: string | null
  /** `icon` is the compact card cue; `full` adds the label and check date. */
  variant?: 'icon' | 'full'
}

const props = withDefaults(defineProps<Props>(), { verifiedAt: null, variant: 'icon' })

const { t, locale } = useI18n()

/**
 * Only the top level earns the orange accent (design.md: orange is a small
 * trust cue, never decoration). Lower levels stay neutral so the badge stack
 * never turns into color noise.
 */
const ICONS: Record<TrustLevel, string> = {
  verified_team: 'i-lucide-badge-check',
  recommended_expats: 'i-lucide-users',
  under_review: 'i-lucide-clock'
}

const TONE: Record<TrustLevel, string> = {
  verified_team: 'text-primary',
  recommended_expats: 'text-muted',
  under_review: 'text-dimmed'
}

const label = computed(() => t(`trust.levels.${props.level}`))
const icon = computed(() => ICONS[props.level])

/**
 * The check date is only meaningful for a TRUSTED level. `last_verified_at` is
 * also stamped on `under_review` rows (it is the "last touched" time), and
 * rendering it there produced "На проверке · 18.08.2026" - which reads as
 * "checked on 18.08" beside a badge that says nothing is confirmed.
 */
const checkedOn = computed(() => {
  if (props.level === 'under_review' || !props.verifiedAt) return ''
  const [year, month, day] = props.verifiedAt.slice(0, 10).split('-')
  const date = locale.value === 'en' ? `${day}/${month}/${year}` : `${day}.${month}.${year}`
  return t('trust.checkedOn', { date })
})

/** Tooltip/aria text: the badge is meaningless without why it is trusted. */
const description = computed(() =>
  props.level === 'under_review'
    ? `${label.value} - ${t('trust.underReviewHint')}`
    : checkedOn.value
      ? `${label.value} - ${checkedOn.value}`
      : label.value
)
</script>

<template>
  <span
    v-if="variant === 'icon'"
    class="inline-flex shrink-0"
    :title="description"
  >
    <UIcon
      :name="icon"
      class="size-4 shrink-0"
      :class="TONE[level]"
      :aria-label="description"
      role="img"
    />
  </span>
  <span
    v-else
    class="inline-flex items-center gap-1.5 text-xs"
    :title="description"
  >
    <UIcon
      :name="icon"
      class="size-3.5 shrink-0"
      :class="TONE[level]"
    />
    <span :class="level === 'under_review' ? 'text-dimmed' : 'text-muted'">
      {{ label }}
      <template v-if="checkedOn"> · {{ checkedOn }}</template>
    </span>
  </span>
</template>
