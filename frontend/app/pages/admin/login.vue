<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import { getSupabaseClient } from '~/composables/useSupabaseClient'

definePageMeta({ layout: 'admin-login' })

const { t } = useI18n()

const email = ref('')
const password = ref('')
const submitting = ref(false)
const errorMessage = ref<string | null>(null)

const client = getSupabaseClient()
const configured = !!client

// An authenticated staff member has nothing to do on the login page.
onMounted(async () => {
  if (!client) return
  const {
    data: { session }
  } = await client.auth.getSession()
  if (!session) return
  const { data } = await client
    .from('profiles')
    .select('role')
    .eq('id', session.user.id)
    .maybeSingle()
  const role = data?.role
  if (role && ['admin', 'curator', 'moderator'].includes(role)) await navigateTo('/admin')
})

const submit = async () => {
  if (!client || !email.value || !password.value) return
  submitting.value = true
  errorMessage.value = null
  try {
    const { error } = await client.auth.signInWithPassword({
      email: email.value,
      password: password.value
    })
    if (error) {
      errorMessage.value = error.message
      return
    }
    await navigateTo('/admin')
  } catch (e) {
    errorMessage.value = e instanceof Error ? e.message : String(e)
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="space-y-6">
    <header class="space-y-2">
      <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
        {{ t('admin.login.title') }}
      </h1>
      <p class="text-base text-muted">
        {{ t('admin.login.subtitle') }}
      </p>
    </header>

    <UAlert
      v-if="!configured"
      color="warning"
      variant="soft"
      :title="t('admin.login.required')"
    />

    <form
      v-else
      class="space-y-5"
      @submit.prevent="submit"
    >
      <div class="space-y-1.5">
        <label
          for="admin-email"
          class="text-sm font-medium text-default"
        >{{ t('admin.login.email') }} <span class="text-error">*</span></label>
        <UInput
          id="admin-email"
          v-model="email"
          class="w-full"
          type="email"
          size="xl"
          autocomplete="email"
          :placeholder="t('admin.login.email')"
        />
      </div>
      <div class="space-y-1.5">
        <label
          for="admin-password"
          class="text-sm font-medium text-default"
        >{{ t('admin.login.password') }} <span class="text-error">*</span></label>
        <UInput
          id="admin-password"
          v-model="password"
          class="w-full"
          type="password"
          size="xl"
          autocomplete="current-password"
          :placeholder="t('admin.login.password')"
        />
      </div>

      <UAlert
        v-if="errorMessage"
        color="error"
        variant="soft"
        :title="t('admin.login.error')"
        :description="errorMessage"
      />

      <UButton
        type="submit"
        block
        size="xl"
        color="neutral"
        :loading="submitting"
        :disabled="!email || !password"
      >
        {{ t('admin.login.submit') }}
      </UButton>
    </form>
  </div>
</template>
