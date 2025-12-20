/**
 * Analytics Service
 * 
 * Provides structured event tracking for the mobile app.
 * Currently uses console.log for development, but designed to be easily
 * swapped for GA4, Firebase Analytics, or other providers.
 */

export type AnalyticsEvent =
  | AppOpenEvent
  | ScreenViewEvent
  | ContentViewEvent
  | VideoPlayEvent
  | VideoCompleteEvent
  | AudioPlayEvent
  | ExternalLinkEvent;

export interface AppOpenEvent {
  event: 'app_open';
  timestamp: number;
  app_name?: string;
}

export interface ScreenViewEvent {
  event: 'screen_view';
  screen_name: string;
  screen_path: string;
  timestamp: number;
}

export interface ContentViewEvent {
  event: 'content_view';
  content_id: string;
  content_type: string;
  content_title?: string;
  timestamp: number;
}

export interface VideoPlayEvent {
  event: 'video_play';
  video_id?: string;
  video_source?: 'youtube' | 'vimeo' | 'url' | 'unknown';
  video_title?: string;
  content_id?: string;
  timestamp: number;
}

export interface VideoCompleteEvent {
  event: 'video_complete';
  video_id?: string;
  video_source?: 'youtube' | 'vimeo' | 'url' | 'unknown';
  video_title?: string;
  content_id?: string;
  timestamp: number;
}

export interface AudioPlayEvent {
  event: 'audio_play';
  audio_id?: string;
  audio_title?: string;
  content_id?: string;
  timestamp: number;
}

export interface ExternalLinkEvent {
  event: 'external_link';
  link_url: string;
  link_text?: string;
  content_id?: string;
  timestamp: number;
}

/**
 * Analytics implementation interface
 * Allows swapping implementations without changing call sites
 */
interface AnalyticsImplementation {
  track(event: AnalyticsEvent): void;
}

/**
 * Console-based analytics implementation (development)
 */
class ConsoleAnalytics implements AnalyticsImplementation {
  track(event: AnalyticsEvent): void {
    if (typeof window === 'undefined') return;
    
    // Format event for console output
    const logMessage = `[Analytics] ${event.event}`;
    const logData: Record<string, unknown> = {
      ...event,
    };
    
    // Remove timestamp from log data for cleaner output (it's in the event)
    delete logData.timestamp;
    
    console.log(logMessage, logData);
    
    // Also dispatch custom event for testing/monitoring
    if (typeof window !== 'undefined') {
      window.dispatchEvent(
        new CustomEvent('analytics:track', {
          detail: event,
        })
      );
    }
  }
}

/**
 * Future: GA4 Analytics implementation
 * 
 * Example:
 * 
 * class GA4Analytics implements AnalyticsImplementation {
 *   track(event: AnalyticsEvent): void {
 *     if (typeof window === 'undefined' || !window.gtag) return;
 *     
 *     const eventName = event.event.replace('_', '-');
 *     window.gtag('event', eventName, {
 *       ...event,
 *     });
 *   }
 * }
 */

/**
 * Future: Firebase Analytics implementation
 * 
 * Example:
 * 
 * class FirebaseAnalytics implements AnalyticsImplementation {
 *   track(event: AnalyticsEvent): void {
 *     if (typeof window === 'undefined' || !window.firebase) return;
 *     
 *     const analytics = window.firebase.analytics();
 *     analytics.logEvent(event.event, event);
 *   }
 * }
 */

// Initialize analytics implementation
let analyticsImpl: AnalyticsImplementation = new ConsoleAnalytics();

/**
 * Set a custom analytics implementation
 * Useful for testing or switching providers
 */
export function setAnalyticsImplementation(impl: AnalyticsImplementation): void {
  analyticsImpl = impl;
}

/**
 * Get current analytics implementation
 * Useful for testing
 */
export function getAnalyticsImplementation(): AnalyticsImplementation {
  return analyticsImpl;
}

/**
 * Track an analytics event
 */
export function trackEvent(event: AnalyticsEvent): void {
  analyticsImpl.track(event);
}

/**
 * Track app open event
 */
export function trackAppOpen(appName?: string): void {
  trackEvent({
    event: 'app_open',
    timestamp: Date.now(),
    app_name: appName,
  });
}

/**
 * Track screen view event
 */
export function trackScreenView(screenName: string, screenPath: string): void {
  trackEvent({
    event: 'screen_view',
    screen_name: screenName,
    screen_path: screenPath,
    timestamp: Date.now(),
  });
}

/**
 * Track content view event
 */
export function trackContentView(
  contentId: string,
  contentType: string,
  contentTitle?: string
): void {
  trackEvent({
    event: 'content_view',
    content_id: contentId,
    content_type: contentType,
    content_title: contentTitle,
    timestamp: Date.now(),
  });
}

/**
 * Track video play event
 */
export function trackVideoPlay(params: {
  videoId?: string;
  videoSource?: 'youtube' | 'vimeo' | 'url' | 'unknown';
  videoTitle?: string;
  contentId?: string;
}): void {
  trackEvent({
    event: 'video_play',
    video_id: params.videoId,
    video_source: params.videoSource,
    video_title: params.videoTitle,
    content_id: params.contentId,
    timestamp: Date.now(),
  });
}

/**
 * Track video complete event
 */
export function trackVideoComplete(params: {
  videoId?: string;
  videoSource?: 'youtube' | 'vimeo' | 'url' | 'unknown';
  videoTitle?: string;
  contentId?: string;
}): void {
  trackEvent({
    event: 'video_complete',
    video_id: params.videoId,
    video_source: params.videoSource,
    video_title: params.videoTitle,
    content_id: params.contentId,
    timestamp: Date.now(),
  });
}

/**
 * Track audio play event
 */
export function trackAudioPlay(params: {
  audioId?: string;
  audioTitle?: string;
  contentId?: string;
}): void {
  trackEvent({
    event: 'audio_play',
    audio_id: params.audioId,
    audio_title: params.audioTitle,
    content_id: params.contentId,
    timestamp: Date.now(),
  });
}

/**
 * Track external link click event
 */
export function trackExternalLink(params: {
  linkUrl: string;
  linkText?: string;
  contentId?: string;
}): void {
  trackEvent({
    event: 'external_link',
    link_url: params.linkUrl,
    link_text: params.linkText,
    content_id: params.contentId,
    timestamp: Date.now(),
  });
}

declare global {
  interface Window {
    __mipAnalytics?: {
      trackEvent: typeof trackEvent;
      trackAppOpen: typeof trackAppOpen;
      trackScreenView: typeof trackScreenView;
      trackContentView: typeof trackContentView;
      trackVideoPlay: typeof trackVideoPlay;
      trackVideoComplete: typeof trackVideoComplete;
      trackAudioPlay: typeof trackAudioPlay;
      trackExternalLink: typeof trackExternalLink;
      setAnalyticsImplementation: typeof setAnalyticsImplementation;
      getAnalyticsImplementation: typeof getAnalyticsImplementation;
    };
  }
}

// Expose analytics to window for debugging and testing
if (typeof window !== 'undefined') {
  window.__mipAnalytics = {
    trackEvent,
    trackAppOpen,
    trackScreenView,
    trackContentView,
    trackVideoPlay,
    trackVideoComplete,
    trackAudioPlay,
    trackExternalLink,
    setAnalyticsImplementation,
    getAnalyticsImplementation,
  };
}
