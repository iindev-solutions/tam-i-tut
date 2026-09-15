<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

import type { GuideEntry } from '~/types/content'

const { t } = useI18n()
const { db } = useDb()
const { tt } = useLocalized()

const selectedCity = useState<string>('selectedCity', () => 'da-nang')

// Emergency numbers are a per-country fact, so the block follows the header
// city selector instead of showing every city's numbers at once.
const contacts = computed(() => db.value.contacts.filter(contact => contact.citySlug === selectedCity.value))

// Consular facts live in the database, not in i18n copy: they change, they need
// a source, and an admin must be able to correct them (the old hardcoded string
// shipped a wrong street for months).
const consulates = computed(() => db.value.consulates.filter(c => c.citySlug === selectedCity.value))

const dial = (number: string) => `tel:${number.replace(/[^\d+]/g, '')}`

const tips = computed<GuideEntry[]>(() =>
  db.value.guides.filter(guide => guide.category === 'safety' && guide.status === 'published')
)
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t('safety.kicker') }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t('safety.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('safety.description') }}
        </p>
      </header>

      <section class="space-y-4">
        <h2 class="text-2xl font-semibold text-highlighted">
          {{ t('safety.contactsTitle') }}
        </h2>
        <!-- A number you cannot tap is useless in a crisis: the TMA is
             phone-only, so every card is a tel: link. Digits are stripped
             because tel: rejects the spaces these numbers are written with. -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <a
            v-for="contact in contacts"
            :key="contact.id"
            :href="`tel:${contact.number.replace(/[^\d+]/g, '')}`"
            class="rounded-2xl border border-default bg-elevated p-5 text-center shadow-sm transition-colors hover:border-primary/40 hover:bg-elevated/70"
          >
            <span class="block text-3xl font-semibold tracking-tight text-highlighted">
              {{ contact.number }}
            </span>
            <span class="mt-1 block text-sm text-muted">
              {{ tt(contact.label) }}
            </span>
          </a>
        </div>
        <p
          v-if="contacts.length === 0"
          class="rounded-xl border border-default bg-elevated/50 p-6 text-center text-sm text-muted"
        >
          {{ t('safety.contactsEmpty') }}
        </p>
        <!-- Consular contact rendered from the DB: address in the Vietnamese
             form for a taxi driver, both numbers tappable, updates in place. -->
        <div
          v-for="consulate in consulates"
          :key="consulate.id"
          class="space-y-2 rounded-xl border border-default bg-elevated/50 p-4"
        >
          <p class="flex items-center gap-2 text-sm font-medium text-highlighted">
            <UIcon
              name="i-lucide-landmark"
              class="size-4 shrink-0 text-muted"
            />
            {{ tt(consulate.name) }}
          </p>
          <p class="text-sm text-muted">
            {{ consulate.address }}
          </p>
          <p class="text-xs text-dimmed">
            {{ tt(consulate.hours) }}
          </p>
          <div class="flex flex-wrap gap-2 pt-1">
            <UButton
              v-if="consulate.phone"
              :to="dial(consulate.phone)"
              color="neutral"
              variant="soft"
              size="xs"
              icon="i-lucide-phone"
              :label="consulate.phone"
            />
            <UButton
              v-if="consulate.emergencyPhone"
              :to="dial(consulate.emergencyPhone)"
              color="primary"
              variant="soft"
              size="xs"
              icon="i-lucide-siren"
              :label="`${t('safety.emergencyLine')}: ${consulate.emergencyPhone}`"
            />
          </div>
        </div>
      </section>

      <section class="space-y-4">
        <h2 class="text-2xl font-semibold text-highlighted">
          {{ t('safety.tipsTitle') }}
        </h2>
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <UCard
            v-for="tip in tips"
            :key="tip.id"
            class="border-default"
            :ui="{ body: 'p-5' }"
          >
            <div class="space-y-3">
              <!-- Level + date on their own line, matching the other guide
                   pages: inline with the title it squeezes at 340px. -->
              <div class="flex items-start justify-between gap-3">
                <p class="text-sm font-medium text-highlighted">
                  {{ tt(tip.title) }}
                </p>
                <UIcon
                  :name="tip.icon || 'i-lucide-shield-check'"
                  class="size-5 shrink-0 text-muted"
                />
              </div>
              <TrustBadge
                :level="tip.trustLevel"
                :verified-at="tip.lastVerifiedAt"
                variant="full"
              />
              <GuideText
                :text="tt(tip.note)"
                variant="note"
              />
              <GuideText
                :text="tt(tip.summary)"
                variant="summary"
                class="text-sm leading-6 text-muted"
              />
            </div>
          </UCard>
        </div>
      </section>
    </div>
  </UContainer>
</template>
