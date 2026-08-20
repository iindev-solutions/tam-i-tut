<script setup lang="ts" generic="T extends { id: string }">
import { useI18n } from 'vue-i18n'

export interface AdminColumn {
  key: string
  label: string
  align?: 'left' | 'right'
}

interface Props {
  columns?: AdminColumn[]
  rows?: T[]
  loading?: boolean
}

withDefaults(defineProps<Props>(), {
  columns: () => [],
  rows: () => [],
  loading: false
})

const { t } = useI18n()
</script>

<template>
  <div class="overflow-x-auto rounded-2xl border border-default bg-elevated shadow-sm">
    <table class="w-full min-w-[32rem] text-sm">
      <thead>
        <tr class="border-b border-default">
          <th
            v-for="column in columns"
            :key="column.key"
            scope="col"
            class="whitespace-nowrap px-4 py-3 text-xs font-medium tracking-wide text-muted uppercase"
            :class="column.align === 'right' ? 'text-right' : 'text-left'"
          >
            {{ column.label }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-if="loading">
          <td
            :colspan="columns.length"
            class="px-4 py-8 text-center text-muted"
          >
            <span class="inline-flex items-center gap-2">
              <UIcon
                name="i-lucide-loader-circle"
                class="size-4 animate-spin"
              />
              Loading…
            </span>
          </td>
        </tr>
        <template v-else-if="rows.length">
          <tr
            v-for="row in rows"
            :key="row.id"
            class="border-b border-default last:border-0"
          >
            <td
              v-for="column in columns"
              :key="column.key"
              class="px-4 py-3 align-middle"
              :class="column.align === 'right' ? 'text-right' : 'text-left'"
            >
              <slot
                :name="`cell-${column.key}`"
                :row="row"
              >
                {{ row[column.key as keyof T] }}
              </slot>
            </td>
          </tr>
        </template>
        <tr v-else>
          <td
            :colspan="columns.length"
            class="px-4 py-8 text-center text-muted"
          >
            <slot name="empty">
              {{ t('admin.empty') }}
            </slot>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
