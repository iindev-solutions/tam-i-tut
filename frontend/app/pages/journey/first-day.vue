<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const steps = [
  { id: 'sim', icon: 'i-lucide-smartphone', labelKey: 'firstDay.steps.sim.label', hintKey: 'firstDay.steps.sim.hint' },
  { id: 'cash', icon: 'i-lucide-banknote', labelKey: 'firstDay.steps.cash.label', hintKey: 'firstDay.steps.cash.hint', to: '/categories/money' },
  { id: 'ride', icon: 'i-lucide-car-taxi-front', labelKey: 'firstDay.steps.ride.label', hintKey: 'firstDay.steps.ride.hint', to: '/categories/transport' },
  { id: 'housing', icon: 'i-lucide-house', labelKey: 'firstDay.steps.housing.label', hintKey: 'firstDay.steps.housing.hint', to: '/categories/housing' },
  { id: 'food', icon: 'i-lucide-utensils', labelKey: 'firstDay.steps.food.label', hintKey: 'firstDay.steps.food.hint', to: '/categories/food' }
]

const done = useState<Set<string>>('first-day-done', () => new Set())

const doneCount = computed(() => steps.filter(step => done.value.has(step.id)).length)

const toggle = (id: string) => {
  const next = new Set(done.value)
  if (next.has(id)) next.delete(id)
  else next.add(id)
  done.value = next
}
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t('firstDay.kicker') }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t('firstDay.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('firstDay.description') }}
        </p>
        <p class="pt-2 text-sm font-medium text-highlighted">
          {{ t('firstDay.progress', { done: doneCount, total: steps.length }) }}
        </p>
      </header>

      <section class="space-y-3">
        <div
          v-for="step in steps"
          :key="step.id"
          class="rounded-3xl border border-default bg-elevated p-5 shadow-sm"
        >
          <div class="flex items-start gap-4">
            <button
              type="button"
              class="mt-0.5 flex size-6 shrink-0 items-center justify-center rounded-full border transition-colors"
              :class="done.has(step.id)
                ? 'border-primary bg-primary/10 text-primary'
                : 'border-default text-transparent hover:border-primary/40'"
              :aria-pressed="done.has(step.id)"
              :aria-label="t('firstDay.done')"
              @click="toggle(step.id)"
            >
              <UIcon
                name="i-lucide-check"
                class="size-4"
              />
            </button>
            <div class="min-w-0 flex-1">
              <p
                class="flex items-center gap-2 text-sm font-medium"
                :class="done.has(step.id) ? 'text-muted line-through' : 'text-highlighted'"
              >
                <UIcon
                  :name="step.icon"
                  class="size-4 shrink-0 text-muted"
                />
                {{ t(step.labelKey) }}
              </p>
              <p class="mt-1.5 text-sm leading-6 text-muted">
                {{ t(step.hintKey) }}
              </p>
              <NuxtLink
                v-if="step.to"
                :to="step.to"
                class="mt-2 inline-flex items-center gap-1 text-sm text-highlighted transition-colors hover:text-primary"
              >
                {{ t('firstDay.openCategory') }}
                <UIcon
                  name="i-lucide-arrow-right"
                  class="size-4"
                />
              </NuxtLink>
            </div>
          </div>
        </div>
      </section>
    </div>
  </UContainer>
</template>
