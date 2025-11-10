/**
 * Composable for handling media URLs from the backend
 * Converts relative media URLs to absolute URLs
 */
export const useMedia = () => {
  const config = useRuntimeConfig()

  /**
   * Get the backend base URL (without /api)
   */
  const getBackendUrl = () => {
    const apiBase = config.public.apiBase
    // Remove /api from the end to get the backend base URL
    return apiBase.replace(/\/api\/?$/, '')
  }

  /**
   * Convert a media URL to an absolute URL
   * @param mediaUrl - The media URL from the API (can be relative or absolute)
   * @returns The absolute URL
   */
  const getMediaUrl = (mediaUrl: string | null | undefined): string | null => {
    if (!mediaUrl) return null

    // If already an absolute URL, return as-is
    if (mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://')) {
      console.log('✅ Using absolute URL:', mediaUrl)
      return mediaUrl
    }

    // Construct absolute URL
    const backendUrl = getBackendUrl()
    // Ensure no double slashes
    const cleanUrl = mediaUrl.startsWith('/') ? mediaUrl : `/${mediaUrl}`
    const fullUrl = `${backendUrl}${cleanUrl}`
    console.log('🔧 Converted relative URL:', mediaUrl, '→', fullUrl)
    return fullUrl
  }

  return {
    getMediaUrl,
    getBackendUrl
  }
}
