<script setup lang="ts">
const { t } = useI18n()

const mvpCards = [
	{
		title: 'verified listings',
		description: 'Housing, transport, jobs, and local services with moderator vetting and trust signals.'
	},
	{
		title: 'community safety',
		description: 'Scam reports with evidence, public blacklist visibility, and moderation queue workflows.'
	},
	{
		title: 'telegram + web access',
		description: 'Telegram Mini App first, with responsive web fallback for SEO and desktop discovery.'
	}
]
</script>

<template>
	<div class="space-y-6">
		<div class="space-y-2">
			<p class="text-sm uppercase tracking-[0.3em] text-cyan-300">{{ t('home.kicker') }}</p>
			<h2 class="text-3xl font-semibold text-white">{{ t('home.title') }}</h2>
			<p class="max-w-2xl text-sm text-gray-300">{{ t('home.description') }}</p>
		</div>

		<UCard variant="outline">
			<template #header>
				<h3 class="text-base font-medium text-white">{{ t('home.startHere') }}</h3>
			</template>

			<ol class="list-decimal space-y-2 pl-5 text-sm text-gray-200">
				<li>Define Supabase schema for listings, reviews, blacklist, reports.</li>
				<li>Implement Telegram initData auth verification pipeline.</li>
				<li>Build listing search + moderation-ready submission flow.</li>
				<li>Document implementation details in <code>vault/</code>.</li>
			</ol>
		</UCard>

		<div class="grid gap-4 md:grid-cols-3">
			<UCard v-for="card in mvpCards" :key="card.title" variant="outline">
				<h3 class="mb-2 text-base font-medium text-white">{{ card.title }}</h3>
				<p class="text-sm text-gray-300">{{ card.description }}</p>
			</UCard>
		</div>
	</div>
</template>
