<script setup lang="ts">
import { computed } from 'vue'

/**
 * Guide text renderer. Guide notes carry "Name: URL | Name: URL" map links
 * and multi-fact blocks as plain text; summaries are dense prose with the
 * occasional URL. This component makes both readable: notes become bullet
 * rows with tappable map/service links, prose gets inline clickable URLs.
 */
const props = withDefaults(defineProps<{ text?: string, variant?: 'note' | 'summary' }>(), {
  text: '',
  variant: 'summary'
})

const URL_RE = /(https?:\/\/[^\s|]+)/

interface Segment {
  kind: 'link' | 'text'
  label: string
  url: string
}

const segments = computed<Segment[]>(() => {
  const raw = props.text.trim()
  if (!raw) return []
  if (props.variant === 'summary') {
    // Inline prose: split on URLs, keep the words around them as text parts.
    const out: Segment[] = []
    for (const part of raw.split(URL_RE)) {
      if (!part) continue
      if (/^https?:\/\//.test(part)) out.push({ kind: 'link', label: part.replace(/^https?:\/\//, '').slice(0, 42), url: part })
      else out.push({ kind: 'text', label: part, url: '' })
    }
    return out
  }
  // Note mode: " | " separates rows; a row with a URL becomes a link chip.
  return raw
    .split('|')
    .map(part => part.trim())
    .filter(Boolean)
    .map<Segment>((part) => {
      const url = part.match(URL_RE)?.[1] ?? ''
      if (!url) return { kind: 'text', label: part, url: '' }
      let label = part.replace(url, '').replace(/[\u{1F4CD}\u{1F5FA}\u{1F30D}]/gu, '').trim()
      label = label.replace(/[:\s-]+$/, '').trim()
      return { kind: 'link', label: label || url, url }
    })
})
</script>

<template>
  <span v-if="segments.length">
    <!-- Prose with inline links. -->
    <template v-if="variant === 'summary'">
      <template
        v-for="(seg, i) in segments"
        :key="i"
      >
        <span>{{ seg.label }}</span>
        <a
          v-if="seg.kind === 'link'"
          :href="seg.url"
          target="_blank"
          rel="noopener"
          class="break-all text-primary underline decoration-primary/40 underline-offset-2 hover:decoration-primary"
        >{{ seg.label }}</a>
      </template>
    </template>

    <!-- Structured notes: bullets + tappable link rows. -->
    <template v-else>
      <span class="block space-y-2">
        <template
          v-for="(seg, i) in segments"
          :key="i"
        >
          <a
            v-if="seg.kind === 'link'"
            :href="seg.url"
            target="_blank"
            rel="noopener"
            class="flex items-center gap-2 rounded-lg border border-default bg-elevated/60 px-3 py-2 text-xs text-default transition-colors hover:bg-elevated"
          >
            <UIcon
              name="i-lucide-map-pin"
              class="size-3.5 shrink-0 text-primary"
            />
            <span class="truncate">{{ seg.label }}</span>
            <UIcon
              name="i-lucide-external-link"
              class="ml-auto size-3 shrink-0 text-dimmed"
            />
          </a>
          <span
            v-else
            class="flex gap-2 text-xs leading-5 text-muted"
          >
            <UIcon
              name="i-lucide-minus"
              class="mt-1 size-3 shrink-0 text-dimmed"
            />
            <span>{{ seg.label }}</span>
          </span>
        </template>
      </span>
    </template>
  </span>
</template>
