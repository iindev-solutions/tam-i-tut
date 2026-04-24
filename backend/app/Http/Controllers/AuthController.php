<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use RuntimeException;
use Throwable;

class AuthController extends Controller
{
	private const TG_ERROR_INVALID_SIGNATURE = 'TG_AUTH_INVALID_SIGNATURE';
	private const TG_ERROR_EXPIRED_PAYLOAD = 'TG_AUTH_EXPIRED_PAYLOAD';
	private const TG_ERROR_REPLAY_DETECTED = 'TG_AUTH_REPLAY_DETECTED';
	private const TG_ERROR_MALFORMED_PAYLOAD = 'TG_AUTH_MALFORMED_PAYLOAD';
	private const TG_ERROR_INTERNAL = 'TG_AUTH_INTERNAL_ERROR';

	private const TG_PAYLOAD_MAX_AGE_SECONDS = 300;
	private const TG_SESSION_TTL_SECONDS = 3600;

	public function login(Request $request): JsonResponse
	{
		$request->validate([
			'email' => 'required|email',
			'password' => 'required|string'
		]);

		return response()->json([
			'success' => false,
			'message' => 'Email/password login is deprecated. Use Telegram auth endpoint.'
		], 410);
	}

	public function telegram(Request $request): JsonResponse
	{
		$payload = $request->validate([
			'initData' => 'required|string',
			'client_timestamp' => 'nullable|integer',
			'device_fingerprint' => 'nullable|string|max:255'
		]);

		$botToken = (string) (config('services.telegram.bot_token') ?? env('TELEGRAM_BOT_TOKEN', ''));
		if ($botToken === '') {
			return $this->telegramError(
				self::TG_ERROR_INTERNAL,
				'Telegram bot token is not configured.',
				500
			);
		}

		$supabase = $this->resolveSupabaseConfig();
		if ($supabase === null) {
			return $this->telegramError(
				self::TG_ERROR_INTERNAL,
				'Supabase credentials are not configured.',
				500
			);
		}

		try {
			$parsed = $this->parseInitData($payload['initData']);
			if ($parsed === null) {
				return $this->telegramError(
					self::TG_ERROR_MALFORMED_PAYLOAD,
					'Malformed Telegram initData payload.',
					422
				);
			}

			if (!$this->isValidTelegramSignature($parsed, $botToken)) {
				return $this->telegramError(
					self::TG_ERROR_INVALID_SIGNATURE,
					'Telegram signature validation failed.',
					401
				);
			}

			$authDate = (int) ($parsed['auth_date'] ?? 0);
			$now = now()->timestamp;
			if ($authDate <= 0 || abs($now - $authDate) > self::TG_PAYLOAD_MAX_AGE_SECONDS) {
				return $this->telegramError(
					self::TG_ERROR_EXPIRED_PAYLOAD,
					'Telegram payload is expired.',
					401
				);
			}

			$replayKey = 'tg_auth_replay:' . hash('sha256', $payload['initData']);
			if (Cache::has($replayKey)) {
				return $this->telegramError(
					self::TG_ERROR_REPLAY_DETECTED,
					'Replayed Telegram payload detected.',
					409
				);
			}
			Cache::put($replayKey, true, now()->addSeconds(self::TG_PAYLOAD_MAX_AGE_SECONDS));

			$telegramUser = $this->extractTelegramUser($parsed);
			if ($telegramUser === null) {
				return $this->telegramError(
					self::TG_ERROR_MALFORMED_PAYLOAD,
					'Missing or invalid Telegram user payload.',
					422
				);
			}

			$telegramUserId = (int) ($telegramUser['id'] ?? 0);
			if ($telegramUserId <= 0) {
				return $this->telegramError(
					self::TG_ERROR_MALFORMED_PAYLOAD,
					'Invalid telegram_user_id in payload.',
					422
				);
			}

			$localeHint = $this->normalizeLocale($telegramUser['language_code'] ?? null);
			$displayName = $this->resolveDisplayName($telegramUser);

			$profile = $this->upsertSupabaseProfile(
				$supabase,
				$telegramUserId,
				$displayName,
				$localeHint
			);

			$sessionToken = $this->issueSignedSessionToken([
				'sub' => (string) $profile['id'],
				'telegram_user_id' => (int) $profile['telegram_user_id'],
				'role' => (string) $profile['role'],
				'locale' => (string) $profile['locale'],
			]);

			return response()->json([
				'success' => true,
				'auth' => [
					'token' => $sessionToken,
					'token_type' => 'Bearer',
					'expires_in' => self::TG_SESSION_TTL_SECONDS,
				],
				'profile' => [
					'id' => $profile['id'],
					'telegram_user_id' => (int) $profile['telegram_user_id'],
					'display_name' => $profile['display_name'],
					'role' => (string) $profile['role'],
					'locale' => (string) $profile['locale'],
				],
				'meta' => [
					'upsert_mode' => 'supabase_profile_upsert',
					'session_mode' => 'signed_internal_token',
				],
			]);
		} catch (Throwable $e) {
			report($e);

			return $this->telegramError(
				self::TG_ERROR_INTERNAL,
				'Unexpected Telegram auth error.',
				500
			);
		}
	}

	private function parseInitData(string $initData): ?array
	{
		if (trim($initData) === '') {
			return null;
		}

		parse_str($initData, $parsed);
		if (!is_array($parsed) || !isset($parsed['hash']) || !isset($parsed['auth_date'])) {
			return null;
		}

		foreach ($parsed as $value) {
			if (is_array($value) || is_object($value)) {
				return null;
			}
		}

		return $parsed;
	}

	private function isValidTelegramSignature(array $parsed, string $botToken): bool
	{
		$providedHash = (string) ($parsed['hash'] ?? '');
		if ($providedHash === '') {
			return false;
		}

		unset($parsed['hash']);
		ksort($parsed, SORT_STRING);

		$pieces = [];
		foreach ($parsed as $key => $value) {
			$pieces[] = $key . '=' . $value;
		}

		$dataCheckString = implode("\n", $pieces);
		$secretKey = hash_hmac('sha256', $botToken, 'WebAppData', true);
		$computedHash = hash_hmac('sha256', $dataCheckString, $secretKey);

		return hash_equals($computedHash, $providedHash);
	}

	private function extractTelegramUser(array $parsed): ?array
	{
		$userRaw = $parsed['user'] ?? null;
		if (!is_string($userRaw) || trim($userRaw) === '') {
			return null;
		}

		$decoded = json_decode($userRaw, true);
		if (!is_array($decoded)) {
			return null;
		}

		return $decoded;
	}

	private function normalizeLocale(?string $languageCode): string
	{
		return in_array($languageCode, ['ru', 'en'], true) ? $languageCode : 'ru';
	}

	private function resolveDisplayName(array $telegramUser): ?string
	{
		$firstName = trim((string) ($telegramUser['first_name'] ?? ''));
		$lastName = trim((string) ($telegramUser['last_name'] ?? ''));
		$username = trim((string) ($telegramUser['username'] ?? ''));

		$name = trim($firstName . ' ' . $lastName);
		if ($name !== '') {
			return $name;
		}

		if ($username !== '') {
			return '@' . $username;
		}

		return null;
	}

	private function resolveSupabaseConfig(): ?array
	{
		$url = rtrim((string) (config('services.supabase.url') ?? env('SUPABASE_URL', '')), '/');
		$serviceRoleKey = (string) (config('services.supabase.service_role_key') ?? env('SUPABASE_SERVICE_ROLE_KEY', ''));

		if ($url === '' || $serviceRoleKey === '') {
			return null;
		}

		return [
			'url' => $url,
			'service_role_key' => $serviceRoleKey,
		];
	}

	private function upsertSupabaseProfile(array $supabase, int $telegramUserId, ?string $displayName, string $locale): array
	{
		$existing = $this->fetchProfileByTelegramUserId($supabase, $telegramUserId);
		if ($existing !== null) {
			return $this->updateExistingProfile($supabase, $telegramUserId, $displayName, $locale);
		}

		$authUserId = $this->createSupabaseAuthUser($supabase, $telegramUserId, $displayName, $locale);
		return $this->insertProfile($supabase, $authUserId, $telegramUserId, $displayName, $locale);
	}

	private function fetchProfileByTelegramUserId(array $supabase, int $telegramUserId): ?array
	{
		$response = Http::withHeaders($this->supabaseHeaders($supabase))
			->get($supabase['url'] . '/rest/v1/profiles', [
				'select' => 'id,telegram_user_id,display_name,role,locale,is_active',
				'telegram_user_id' => 'eq.' . $telegramUserId,
				'limit' => 1,
			]);

		if (!$response->successful()) {
			throw new RuntimeException('Failed to fetch Supabase profile by telegram_user_id.');
		}

		$rows = $response->json();
		if (!is_array($rows) || count($rows) === 0) {
			return null;
		}

		return $this->normalizeProfileRow($rows[0]);
	}

	private function updateExistingProfile(array $supabase, int $telegramUserId, ?string $displayName, string $locale): array
	{
		$payload = [
			'display_name' => $displayName,
			'locale' => $locale,
			'role' => 'user',
			'is_active' => true,
		];

		$response = Http::withHeaders(array_merge(
			$this->supabaseHeaders($supabase),
			['Prefer' => 'return=representation']
		))
			->patch(
				$supabase['url'] . '/rest/v1/profiles?telegram_user_id=eq.' . $telegramUserId,
				$payload
			);

		if (!$response->successful()) {
			throw new RuntimeException('Failed to update existing Supabase profile.');
		}

		$rows = $response->json();
		if (is_array($rows) && count($rows) > 0) {
			return $this->normalizeProfileRow($rows[0]);
		}

		$profile = $this->fetchProfileByTelegramUserId($supabase, $telegramUserId);
		if ($profile === null) {
			throw new RuntimeException('Supabase profile update returned empty payload.');
		}

		return $profile;
	}

	private function createSupabaseAuthUser(array $supabase, int $telegramUserId, ?string $displayName, string $locale): string
	{
		$email = $this->telegramSyntheticEmail($telegramUserId);
		$response = Http::withHeaders($this->supabaseHeaders($supabase))
			->post($supabase['url'] . '/auth/v1/admin/users', [
				'email' => $email,
				'password' => Str::random(40),
				'email_confirm' => true,
				'user_metadata' => [
					'telegram_user_id' => $telegramUserId,
					'display_name' => $displayName,
					'locale' => $locale,
				],
			]);

		if ($response->successful()) {
			$userId = (string) $response->json('id');
			if ($userId !== '') {
				return $userId;
			}
		}

		$existingAuthUserId = $this->findSupabaseAuthUserIdByEmail($supabase, $email);
		if ($existingAuthUserId !== null) {
			return $existingAuthUserId;
		}

		throw new RuntimeException('Failed to create or resolve Supabase auth user.');
	}

	private function findSupabaseAuthUserIdByEmail(array $supabase, string $email): ?string
	{
		$response = Http::withHeaders($this->supabaseHeaders($supabase))
			->get($supabase['url'] . '/auth/v1/admin/users', [
				'page' => 1,
				'per_page' => 200,
			]);

		if (!$response->successful()) {
			throw new RuntimeException('Failed to query Supabase auth users for fallback lookup.');
		}

		$users = $response->json('users', []);
		if (!is_array($users)) {
			return null;
		}

		$needle = strtolower($email);
		foreach ($users as $user) {
			if (!is_array($user)) {
				continue;
			}

			$candidateEmail = strtolower((string) ($user['email'] ?? ''));
			if ($candidateEmail === $needle) {
				$id = (string) ($user['id'] ?? '');
				if ($id !== '') {
					return $id;
				}
			}
		}

		return null;
	}

	private function insertProfile(array $supabase, string $authUserId, int $telegramUserId, ?string $displayName, string $locale): array
	{
		$response = Http::withHeaders(array_merge(
			$this->supabaseHeaders($supabase),
			['Prefer' => 'return=representation']
		))
			->post($supabase['url'] . '/rest/v1/profiles', [
				'id' => $authUserId,
				'telegram_user_id' => $telegramUserId,
				'display_name' => $displayName,
				'locale' => $locale,
				'role' => 'user',
				'is_active' => true,
			]);

		if (!$response->successful()) {
			throw new RuntimeException('Failed to insert Supabase profile.');
		}

		$rows = $response->json();
		if (is_array($rows) && count($rows) > 0) {
			return $this->normalizeProfileRow($rows[0]);
		}

		$profile = $this->fetchProfileByTelegramUserId($supabase, $telegramUserId);
		if ($profile === null) {
			throw new RuntimeException('Supabase profile insert returned empty payload.');
		}

		return $profile;
	}

	private function normalizeProfileRow(array $row): array
	{
		return [
			'id' => (string) ($row['id'] ?? ''),
			'telegram_user_id' => (int) ($row['telegram_user_id'] ?? 0),
			'display_name' => $row['display_name'] ?? null,
			'role' => (string) ($row['role'] ?? 'user'),
			'locale' => in_array(($row['locale'] ?? null), ['ru', 'en'], true) ? (string) $row['locale'] : 'ru',
		];
	}

	private function supabaseHeaders(array $supabase): array
	{
		$serviceRoleKey = (string) $supabase['service_role_key'];

		return [
			'apikey' => $serviceRoleKey,
			'Authorization' => 'Bearer ' . $serviceRoleKey,
			'Content-Type' => 'application/json',
			'Accept' => 'application/json',
		];
	}

	private function telegramSyntheticEmail(int $telegramUserId): string
	{
		return 'tg_' . $telegramUserId . '@telegram.tamitut.local';
	}

	private function issueSignedSessionToken(array $claims): string
	{
		$header = [
			'alg' => 'HS256',
			'typ' => 'JWT',
		];

		$payload = array_merge($claims, [
			'iat' => now()->timestamp,
			'exp' => now()->addSeconds(self::TG_SESSION_TTL_SECONDS)->timestamp,
			'jti' => (string) Str::uuid(),
		]);

		$encodedHeader = $this->base64UrlEncode(json_encode($header, JSON_UNESCAPED_SLASHES));
		$encodedPayload = $this->base64UrlEncode(json_encode($payload, JSON_UNESCAPED_SLASHES));
		$signature = hash_hmac(
			'sha256',
			$encodedHeader . '.' . $encodedPayload,
			$this->resolveAppSigningKey(),
			true
		);

		return $encodedHeader . '.' . $encodedPayload . '.' . $this->base64UrlEncode($signature);
	}

	private function resolveAppSigningKey(): string
	{
		$key = (string) config('app.key', '');
		if (str_starts_with($key, 'base64:')) {
			$decoded = base64_decode(substr($key, 7), true);
			if ($decoded !== false) {
				return $decoded;
			}
		}

		if ($key !== '') {
			return $key;
		}

		return 'tamitut-dev-fallback-signing-key';
	}

	private function base64UrlEncode(string $value): string
	{
		return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
	}

	private function telegramError(string $code, string $message, int $status): JsonResponse
	{
		return response()->json([
			'success' => false,
			'error' => [
				'code' => $code,
				'message' => $message,
			],
		], $status);
	}
}
