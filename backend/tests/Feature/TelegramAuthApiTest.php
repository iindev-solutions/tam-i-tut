<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class TelegramAuthApiTest extends TestCase
{
	private string $botToken = 'test_bot_token_123';

	protected function setUp(): void
	{
		parent::setUp();

		config(['services.telegram.bot_token' => $this->botToken]);
		putenv('TELEGRAM_BOT_TOKEN=' . $this->botToken);
		$_ENV['TELEGRAM_BOT_TOKEN'] = $this->botToken;
		$_SERVER['TELEGRAM_BOT_TOKEN'] = $this->botToken;

		Cache::flush();
	}

	public function test_valid_payload_passes_and_returns_session_shape(): void
	{
		$initData = $this->buildSignedInitData();

		$this->postJson('/api/auth/telegram', [
			'initData' => $initData,
			'device_fingerprint' => 'device-abc',
		])
			->assertOk()
			->assertJsonPath('success', true)
			->assertJsonPath('profile.telegram_user_id', 123456789)
			->assertJsonPath('profile.role', 'user')
			->assertJsonPath('profile.locale', 'ru');
	}

	public function test_tampered_payload_fails_signature_check(): void
	{
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
	}

	public function test_expired_payload_is_rejected(): void
	{
		$expiredAuthDate = time() - 301;
		$initData = $this->buildSignedInitData([
			'auth_date' => (string) $expiredAuthDate,
		]);

		$this->postJson('/api/auth/telegram', [
			'initData' => $initData,
		])
			->assertStatus(401)
			->assertJsonPath('error.code', 'TG_AUTH_EXPIRED_PAYLOAD');
	}

	public function test_payload_replay_is_rejected(): void
	{
		$initData = $this->buildSignedInitData();

		$this->postJson('/api/auth/telegram', [
			'initData' => $initData,
		])->assertOk();

		$this->postJson('/api/auth/telegram', [
			'initData' => $initData,
		])
			->assertStatus(409)
			->assertJsonPath('error.code', 'TG_AUTH_REPLAY_DETECTED');
	}

	public function test_malformed_payload_is_rejected_with_typed_error(): void
	{
		$this->postJson('/api/auth/telegram', [
			'initData' => 'auth_date=1700000000&user=%7B%22id%22%3A123%7D',
		])
			->assertStatus(422)
			->assertJsonPath('error.code', 'TG_AUTH_MALFORMED_PAYLOAD');
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
