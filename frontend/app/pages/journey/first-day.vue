<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const steps = [
  { id: 'sim', icon: 'i-lucide-smartphone', labelKey: 'firstDay.steps.sim.label', hintKey: 'firstDay.steps.sim.hint', to: '' },
  { id: 'cash', icon: 'i-lucide-banknote', labelKey: 'firstDay.steps.cash.label', hintKey: 'firstDay.steps.cash.hint', to: '/categories/money' },
  { id: 'ride', icon: 'i-lucide-car-taxi-front', labelKey: 'firstDay.steps.ride.label', hintKey: 'firstDay.steps.ride.hint', to: '/categories/transport' },
  { id: 'housing', icon: 'i-lucide-house', labelKey: 'firstDay.steps.housing.label', hintKey: 'firstDay.steps.housing.hint', to: '/categories/housing' },
  { id: 'food', icon: 'i-lucide-utensils', labelKey: 'firstDay.steps.food.label', hintKey: 'firstDay.steps.food.hint', to: '/categories/food' }
]

const done = useState<Set<string>>('first-day-done', () => new Set())

const doneCount = computed(() => steps.filter(step => done.value.has(step.id)).length)
const progressPct = computed(() => Math.round((doneCount.value / steps.length) * 100))

const toggle = (id: string) => {
  const next = new Set(done.value)
  if (next.has(id)) next.delete(id)
  else next.add(id)
  done.value = next
}
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-6">
      <header class="space-y-3">
        <p class="text-sm text-muted">
          {{ t('firstDay.kicker') }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t('firstDay.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('firstDay.description') }}
        </p>
        <div class="flex items-center gap-3 pt-1">
          <div class="h-1.5 flex-1 overflow-hidden rounded-full bg-elevated">
            <div
              class="h-full rounded-full bg-primary transition-all duration-300"
              :style="{ width: `${progressPct}%` }"
            />
          </div>
          <span class="shrink-0 text-sm tabular-nums text-muted">
            {{ t('firstDay.progress', { done: doneCount, total: steps.length }) }}
          </span>
        </div>
      </header>

      <section class="space-y-2.5">
        <div
          v-for="(step, index) in steps"
          :key="step.id"
          class="rounded-2xl border bg-elevated p-4 transition-colors sm:p-5"
          :class="done.has(step.id) ? 'border-primary/30' : 'border-default'"
        >
          <div class="flex items-start gap-3.5">
            <button
              type="button"
              class="flex size-8 shrink-0 items-center justify-center rounded-full border text-sm font-semibold transition-colors"
              :class="done.has(step.id)
                ? 'border-primary bg-primary text-white'
                : 'border-default text-dimmed hover:border-primary/50 hover:text-primary'"
              :aria-pressed="done.has(step.id)"
              :aria-label="t('firstDay.done')"
              @click="toggle(step.id)"
            >
              <UIcon
                v-if="done.has(step.id)"
                name="i-lucide-check"
                class="size-4"
              />
              <span v-else>{{ index + 1 }}</span>
            </button>
            <div class="min-w-0 flex-1">
              <p
                class="flex items-center gap-2 text-sm font-medium"
                :class="done.has(step.id) ? 'text-muted line-through' : 'text-highlighted'"
              >
                {{ t(step.labelKey) }}
                <UIcon
                  :name="step.icon"
                  class="size-4 shrink-0 text-dimmed"
                />
              </p>
              <p class="mt-1 text-sm leading-6 text-muted">
                {{ t(step.hintKey) }}
              </p>
              <NuxtLink
                v-if="step.to"
                :to="step.to"
                class="mt-1.5 inline-flex items-center gap-1 text-xs font-medium text-primary"
              >
                {{ t('firstDay.openCategory') }}
                <UIcon
                  name="i-lucide-arrow-right"
                  class="size-3.5"
                />
              </NuxtLink>
            </div>
          </div>
        </div>
      </section>
    </div>
  </UContainer>
</template>
