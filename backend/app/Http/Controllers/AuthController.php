<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
	public function login(Request $request): JsonResponse
	{
		$request->validate([
			'email' => 'required|email',
			'password' => 'required|string'
		]);

		return response()->json([
			'success' => false,
			'message' => 'Replace this placeholder action with real TamITut auth.'
		], 501);
	}
}
