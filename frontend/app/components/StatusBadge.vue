<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

export type BadgeStatus = 'published' | 'draft' | 'pending' | 'approved' | 'rejected' | 'active' | 'comingSoon'

interface Props {
  status: BadgeStatus
}

const props = defineProps<Props>()
const { t } = useI18n()

const toneMap: Record<BadgeStatus, 'neutral' | 'warning' | 'error'> = {
  published: 'neutral',
  active: 'neutral',
  approved: 'neutral',
  draft: 'warning',
  pending: 'warning',
  rejected: 'error',
  comingSoon: 'warning'
}

const color = computed(() => toneMap[props.status])
const label = computed(() => t(`status.${props.status}`))
</script>

<template>
  <UBadge
    :color="color"
    variant="subtle"
    size="sm"
  >
    {{ label }}
  </UBadge>
</template>
