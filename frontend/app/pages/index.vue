<script setup lang="ts">
const { t } = useI18n()

const guideCards = [
	{
		title: '2 taps to answer',
		description: 'User should reach useful guidance in at most two taps from main screen or search.'
	},
	{
		title: '3-level trust badges',
		description: 'Verified by team, Recommended by expats (3+ trusted confirmations), or Under review.'
	},
	{
		title: 'curated, not classifieds',
		description: 'No open user listings. Team-controlled guide entries with evidence and moderation.'
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
				<li>Model six MVP categories with contacts, checklists, and benchmark prices.</li>
				<li>Implement trust workflow with badges, evidence rules, and review timestamps.</li>
				<li>Ship blacklist + scam-pattern content with strict evidence moderation.</li>
				<li>Build Russian-primary Telegram flow with parallel English content layer.</li>
			</ol>
		</UCard>

		<div class="grid gap-4 md:grid-cols-3">
			<UCard v-for="card in guideCards" :key="card.title" variant="outline">
				<h3 class="mb-2 text-base font-medium text-white">{{ card.title }}</h3>
				<p class="text-sm text-gray-300">{{ card.description }}</p>
			</UCard>
		</div>
	</div>
</template>
