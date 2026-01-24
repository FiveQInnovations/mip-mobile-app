import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { WebView } from 'react-native-webview';
import { getConfig } from '../lib/config';

interface AudioPlayerProps {
  url: string;
  title?: string;
  artist?: string;
}

export function AudioPlayer({ url, title, artist }: AudioPlayerProps) {
  const config = getConfig();
  const primaryColor = config.primaryColor || '#D9232A';
  const [error, setError] = useState<string | null>(null);

  // Validate URL before rendering
  if (!url) {
    return (
      <View style={styles.container} testID="audio-player-container">
        {(title || artist) && (
          <View style={styles.metadata}>
            {title && <Text style={styles.title} numberOfLines={1}>{title}</Text>}
            {artist && <Text style={styles.artist} numberOfLines={1}>{artist}</Text>}
          </View>
        )}
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>No audio URL provided</Text>
        </View>
      </View>
    );
  }

  // Handle messages from WebView (error reporting)
  const handleMessage = (event: any) => {
    try {
      const data = JSON.parse(event.nativeEvent.data);
      console.log('[AudioPlayer] WebView message:', data);
      
      if (data.type === 'error') {
        console.error('[AudioPlayer] Audio error:', data.error, 'URL:', data.url);
        setError(data.error || 'Failed to load audio');
      } else if (data.type === 'loaded') {
        // Clear error on successful load
        setError(null);
      }
    } catch (e) {
      console.warn('[AudioPlayer] Failed to parse WebView message:', e);
    }
  };

  // Handle WebView errors
  const handleWebViewError = (syntheticEvent: any) => {
    const { nativeEvent } = syntheticEvent;
    console.error('[AudioPlayer] WebView error:', nativeEvent);
    setError('Failed to load audio player');
  };

  // Escape URL for use in HTML
  const escapedUrl = url.replace(/\\/g, '\\\\').replace(/`/g, '\\`').replace(/\$/g, '\\$');

  // Inline HTML with native audio element and error handling
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
          font-family: -apple-system, sans-serif; 
          background: transparent; 
          padding: 0;
        }
        audio { 
          width: 100%; 
          height: 54px; 
        }
        audio::-webkit-media-controls-panel { 
          background: #f8fafc; 
        }
      </style>
    </head>
    <body>
      <audio 
        id="audioElement"
        controls 
        preload="metadata" 
        src="${escapedUrl}"
        onerror="window.ReactNativeWebView.postMessage(JSON.stringify({
          type: 'error',
          error: this.error ? (this.error.message || 'Unknown error') : 'Failed to load audio',
          url: '${escapedUrl}'
        }))"
        onloadeddata="window.ReactNativeWebView.postMessage(JSON.stringify({
          type: 'loaded',
          url: '${escapedUrl}'
        }))"
      ></audio>
      <script>
        // Additional error handling
        window.addEventListener('error', function(e) {
          window.ReactNativeWebView.postMessage(JSON.stringify({
            type: 'error',
            error: e.message || 'JavaScript error',
            url: '${escapedUrl}'
          }));
        });
        
        // Listen for audio element errors
        document.getElementById('audioElement').addEventListener('error', function(e) {
          var errorMsg = 'Unknown error';
          if (this.error) {
            switch(this.error.code) {
              case 1: errorMsg = 'Aborted'; break;
              case 2: errorMsg = 'Network error'; break;
              case 3: errorMsg = 'Decode error'; break;
              case 4: errorMsg = 'Source not supported'; break;
              default: errorMsg = 'Error code: ' + this.error.code;
            }
          }
          window.ReactNativeWebView.postMessage(JSON.stringify({
            type: 'error',
            error: errorMsg,
            url: '${escapedUrl}'
          }));
        });
      </script>
    </body>
    </html>
  `;

  return (
    <View style={styles.container} testID="audio-player-container">
      {(title || artist) && (
        <View style={styles.metadata}>
          {title && <Text style={styles.title} numberOfLines={1}>{title}</Text>}
          {artist && <Text style={styles.artist} numberOfLines={1}>{artist}</Text>}
        </View>
      )}
      {error ? (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>Error: {error}</Text>
          <Text style={styles.errorUrl} numberOfLines={1}>URL: {url}</Text>
        </View>
      ) : (
        <WebView
          testID="audio-webview"
          source={{ html }}
          style={styles.webview}
          scrollEnabled={false}
          allowsInlineMediaPlayback={true}
          mediaPlaybackRequiresUserAction={false}
          onMessage={handleMessage}
          onError={handleWebViewError}
          onHttpError={(syntheticEvent) => {
            const { nativeEvent } = syntheticEvent;
            console.error('[AudioPlayer] HTTP error:', nativeEvent.statusCode);
            setError(`HTTP ${nativeEvent.statusCode}: Failed to load audio`);
          }}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#f8fafc',
    borderRadius: 12,
    padding: 16,
    marginVertical: 12,
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  metadata: {
    marginBottom: 12,
  },
  title: {
    fontSize: 17,
    fontWeight: '600',
    color: '#0f172a',
    marginBottom: 4,
  },
  artist: {
    fontSize: 14,
    color: '#64748b',
  },
  webview: {
    height: 54,
    backgroundColor: 'transparent',
  },
  errorContainer: {
    padding: 12,
    backgroundColor: '#fee2e2',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#fecaca',
  },
  errorText: {
    fontSize: 14,
    color: '#dc2626',
    fontWeight: '600',
    marginBottom: 4,
  },
  errorUrl: {
    fontSize: 11,
    color: '#991b1b',
    fontFamily: 'monospace',
  },
});
