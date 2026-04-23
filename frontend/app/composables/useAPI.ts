import type { ApiResponse } from '~/app/types/api'

export const useAPI = () => {
	const config = useRuntimeConfig()

	const baseURL = computed(() => (config.public.apiBase as string) || 'http://localhost:8000/api')

	const request = async <T>(endpoint: string, options: { method?: string; body?: Record<string, unknown> } = {}) => {
		const { method = 'GET', body } = options
		const url = `${baseURL.value}${endpoint.startsWith('/') ? '' : '/'}${endpoint}`

		return await $fetch<T>(url, {
			method,
			body
		})
	}

	const get = <T>(endpoint: string) => request<ApiResponse<T>>(endpoint)
	const post = <T>(endpoint: string, body?: Record<string, unknown>) => request<ApiResponse<T>>(endpoint, { method: 'POST', body })

	return {
		baseURL,
		request,
		get,
		post
	}
}
