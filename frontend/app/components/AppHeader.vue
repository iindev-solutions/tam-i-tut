<script setup lang="ts">
const config = useRuntimeConfig()
</script>

<template>
	<header class="border-b border-white/10 bg-black/20 backdrop-blur">
		<div class="mx-auto flex max-w-4xl items-center justify-between px-4 py-4">
			<div>
				<p class="text-xs uppercase tracking-[0.3em] text-cyan-300">TamITut</p>
				<h1 class="text-lg font-semibold text-white">{{ config.public.appName }}</h1>
			</div>
			<UBadge color="primary" variant="subtle">trust-first MVP</UBadge>
		</div>
	</header>
</template>
