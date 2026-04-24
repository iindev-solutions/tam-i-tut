<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class TelegramAuthApiTest extends TestCase
{
	private string $botToken = 'test_bot_token_123';
	private string $supabaseUrl = 'https://example.supabase.co';
	private string $supabaseServiceRoleKey = 'supabase_service_role_test_key';

	protected function setUp(): void
	{
		parent::setUp();

		config([
			'services.telegram.bot_token' => $this->botToken,
			'services.supabase.url' => $this->supabaseUrl,
			'services.supabase.service_role_key' => $this->supabaseServiceRoleKey,
		]);

		putenv('TELEGRAM_BOT_TOKEN=' . $this->botToken);
		putenv('SUPABASE_URL=' . $this->supabaseUrl);
		putenv('SUPABASE_SERVICE_ROLE_KEY=' . $this->supabaseServiceRoleKey);
		$_ENV['TELEGRAM_BOT_TOKEN'] = $this->botToken;
		$_ENV['SUPABASE_URL'] = $this->supabaseUrl;
		$_ENV['SUPABASE_SERVICE_ROLE_KEY'] = $this->supabaseServiceRoleKey;
		$_SERVER['TELEGRAM_BOT_TOKEN'] = $this->botToken;
		$_SERVER['SUPABASE_URL'] = $this->supabaseUrl;
		$_SERVER['SUPABASE_SERVICE_ROLE_KEY'] = $this->supabaseServiceRoleKey;

		Cache::flush();
		Http::preventStrayRequests();
	}

	public function test_valid_payload_passes_and_returns_session_shape(): void
	{
		$profileId = '7a7f7f8f-1ed2-4f89-9f95-7cb3b58f6021';
		$this->fakeSupabaseNewProfileFlow($profileId);

		$initData = $this->buildSignedInitData();

		$this->postJson('/api/auth/telegram', [
			'initData' => $initData,
			'device_fingerprint' => 'device-abc',
		])
			->assertOk()
			->assertJsonStructure([
				'auth' => ['token', 'token_type', 'expires_in', 'session_id'],
				'profile' => ['id', 'telegram_user_id', 'display_name', 'role', 'locale'],
			])
			->assertJsonPath('success', true)
			->assertJsonPath('profile.id', $profileId)
			->assertJsonPath('profile.telegram_user_id', 123456789)
			->assertJsonPath('profile.role', 'user')
			->assertJsonPath('profile.locale', 'ru')
			->assertJsonPath('auth.token_type', 'Bearer')
			->assertJsonPath('auth.expires_in', 3600)
			->assertJsonPath('meta.upsert_mode', 'supabase_profile_upsert')
			->assertJsonPath('meta.session_mode', 'opaque_cache_token');

		Http::assertSentCount(3);
	}

	public function test_tampered_payload_fails_signature_check(): void
	{
		Http::fake();

		$initData = $this->buildSignedInitData();
		parse_str($initData, $parsed);

		$originalHash = $parsed['hash'];
		$user = json_decode((string) $parsed['user'], true);
		$user['first_name'] = 'Tampered';
		$parsed['user'] = json_encode($user, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
		$parsed['hash'] = $originalHash;

		$tampered = http_build_query($parsed, '', '&', PHP_QUERY_RFC3986);

		$this->postJson('/api/auth/telegram', [
			'initData' => $tampered,
		])
			->assertStatus(401)
			->assertJsonPath('error.code', 'TG_AUTH_INVALID_SIGNATURE');

		Http::assertNothingSent();
	}

	public function test_expired_payload_is_rejected(): void
	{
		Http::fake();

		$expiredAuthDate = time() - 301;
		$initData = $this->buildSignedInitData([
			'auth_date' => (string) $expiredAuthDate,
		]);

		$this->postJson('/api/auth/telegram', [
			'initData' => $initData,
		])
			->assertStatus(401)
			->assertJsonPath('error.code', 'TG_AUTH_EXPIRED_PAYLOAD');

		Http::assertNothingSent();
	}

	public function test_payload_replay_is_rejected(): void
	{
		$profileId = 'fa4f57c9-05c2-4ce5-8969-33718af93fb6';
		$this->fakeSupabaseNewProfileFlow($profileId);

		$initData = $this->buildSignedInitData();

		$this->postJson('/api/auth/telegram', [
			'initData' => $initData,
		])->assertOk();

		$this->postJson('/api/auth/telegram', [
			'initData' => $initData,
		])
			->assertStatus(409)
			->assertJsonPath('error.code', 'TG_AUTH_REPLAY_DETECTED');

		Http::assertSentCount(3);
	}

	public function test_malformed_payload_is_rejected_with_typed_error(): void
	{
		Http::fake();

		$this->postJson('/api/auth/telegram', [
			'initData' => 'auth_date=1700000000&user=%7B%22id%22%3A123%7D',
		])
			->assertStatus(422)
			->assertJsonPath('error.code', 'TG_AUTH_MALFORMED_PAYLOAD');

		Http::assertNothingSent();
	}

	public function test_missing_supabase_credentials_returns_internal_error(): void
	{
		config([
			'services.supabase.url' => null,
			'services.supabase.service_role_key' => null,
		]);
		putenv('SUPABASE_URL');
		putenv('SUPABASE_SERVICE_ROLE_KEY');

		Http::fake();
		$initData = $this->buildSignedInitData();

		$this->postJson('/api/auth/telegram', [
			'initData' => $initData,
		])
			->assertStatus(500)
			->assertJsonPath('error.code', 'TG_AUTH_INTERNAL_ERROR');

		Http::assertNothingSent();
	}

	private function fakeSupabaseNewProfileFlow(string $profileId): void
	{
		Http::fake([
			$this->supabaseUrl . '/rest/v1/profiles*' => Http::sequence()
				->push([], 200)
				->push([
					[
						'id' => $profileId,
						'telegram_user_id' => 123456789,
						'display_name' => 'Slava Test',
						'role' => 'user',
						'locale' => 'ru',
						'is_active' => true,
					],
				], 201),
			$this->supabaseUrl . '/auth/v1/admin/users' => Http::response([
				'id' => $profileId,
				'email' => 'tg_123456789@telegram.tamitut.local',
			], 200),
		]);
	}

	/**
	 * Build Telegram WebApp initData with valid signature for tests.
	 */
	private function buildSignedInitData(array $overrides = []): string
	{
		$payload = array_merge([
			'auth_date' => (string) time(),
			'query_id' => 'AAEAAAE',
			'user' => json_encode([
				'id' => 123456789,
				'first_name' => 'Slava',
				'last_name' => 'Test',
				'username' => 'slava_test',
				'language_code' => 'ru',
			], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
		], $overrides);

		$signaturePayload = $payload;
		ksort($signaturePayload, SORT_STRING);

		$pairs = [];
		foreach ($signaturePayload as $key => $value) {
			$pairs[] = $key . '=' . $value;
		}
		$dataCheckString = implode("\n", $pairs);

		$secretKey = hash_hmac('sha256', $this->botToken, 'WebAppData', true);
		$hash = hash_hmac('sha256', $dataCheckString, $secretKey);

		$payload['hash'] = $hash;

		return http_build_query($payload, '', '&', PHP_QUERY_RFC3986);
	}
}
