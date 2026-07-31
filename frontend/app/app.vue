<template>
  <UApp>
    <NuxtLoadingIndicator
      color="var(--ui-primary)"
      :height="2"
    />
    <NuxtLayout>
      <NuxtPage :transition="{ name: 'page', mode: 'out-in' }" />
    </NuxtLayout>
  </UApp>
</template>
