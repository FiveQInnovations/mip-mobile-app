import React from 'react';
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

  // Inline HTML with native audio element
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
      <audio controls preload="metadata" src="${url}"></audio>
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
      <WebView
        testID="audio-webview"
        source={{ html }}
        style={styles.webview}
        scrollEnabled={false}
        allowsInlineMediaPlayback={true}
        mediaPlaybackRequiresUserAction={false}
      />
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
});
