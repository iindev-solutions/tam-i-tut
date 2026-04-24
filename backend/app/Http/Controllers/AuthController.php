<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;
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
			$role = 'user';

			$sessionToken = Str::random(64);
			Cache::put(
				'tg_session:' . hash('sha256', $sessionToken),
				[
					'telegram_user_id' => $telegramUserId,
					'role' => $role,
					'locale' => $localeHint,
					'device_fingerprint' => $payload['device_fingerprint'] ?? null,
					'created_at' => now()->toIso8601String(),
				],
				now()->addSeconds(self::TG_SESSION_TTL_SECONDS)
			);

			return response()->json([
				'success' => true,
				'auth' => [
					'token' => $sessionToken,
					'token_type' => 'Bearer',
					'expires_in' => self::TG_SESSION_TTL_SECONDS,
				],
				'profile' => [
					'telegram_user_id' => $telegramUserId,
					'display_name' => $displayName,
					'role' => $role,
					'locale' => $localeHint,
				],
				'meta' => [
					'upsert_mode' => 'transitional_placeholder',
					'note' => 'Move profile upsert/session issuance to Supabase edge/service layer.'
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

		foreach ($parsed as $key => $value) {
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
