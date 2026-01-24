import React, { useEffect, useState, useRef } from 'react';
import { View, Text, StyleSheet, Pressable, ActivityIndicator } from 'react-native';
import { useAudioPlayer, useAudioPlayerStatus, setAudioModeAsync } from 'expo-audio';
import Slider from '@react-native-community/slider';
import { Ionicons } from '@expo/vector-icons';
import { getConfig } from '../lib/config';

interface AudioPlayerProps {
  url: string;
  title?: string;
  artist?: string;
}

export function AudioPlayer({ url, title, artist }: AudioPlayerProps) {
  const config = getConfig();
  const primaryColor = config.primaryColor || '#D9232A';
  const [loadError, setLoadError] = useState<string | null>(null);
  const [isReady, setIsReady] = useState(false);
  const previousUrlRef = useRef<string | null>(null);
  
  console.log('[AudioPlayer] Render - url:', url, 'title:', title);

  // Configure audio mode on mount - important for iOS
  useEffect(() => {
    console.log('[AudioPlayer] Configuring audio mode');
    setAudioModeAsync({
      playsInSilentMode: true,
    }).catch(err => {
      console.error('[AudioPlayer] Error setting audio mode:', err);
    });
  }, []);

  // Create audio player
  const player = useAudioPlayer(url ? { uri: url } : null, {
    updateInterval: 250, // More frequent updates for smoother UI
  });
  const status = useAudioPlayerStatus(player);
  
  console.log('[AudioPlayer] Player status:', {
    isLoaded: status?.isLoaded,
    isBuffering: status?.isBuffering,
    playing: status?.playing,
    currentTime: status?.currentTime,
    duration: status?.duration,
    playbackState: status?.playbackState,
  });

  // Handle URL changes - explicitly replace the source when URL changes
  useEffect(() => {
    if (url && url !== previousUrlRef.current && player) {
      console.log('[AudioPlayer] URL changed, replacing source:', url);
      setIsReady(false);
      setLoadError(null);
      previousUrlRef.current = url;
      
      // Use replace() to load new audio source
      try {
        player.replace({ uri: url });
      } catch (e) {
        console.error('[AudioPlayer] Error replacing source:', e);
      }
    }
  }, [url, player]);
  
  // Track when audio becomes ready
  useEffect(() => {
    if (status?.isLoaded && status?.duration > 0) {
      console.log('[AudioPlayer] Audio is ready, duration:', status.duration);
      setIsReady(true);
    }
  }, [status?.isLoaded, status?.duration]);
  
  // Listen for errors
  useEffect(() => {
    if (player) {
      const handleError = (error: any) => {
        console.error('[AudioPlayer] Player error:', error);
        setLoadError(error?.message || 'Playback error');
      };
      
      // Try to catch any errors from the player
      try {
        const subscription = player.addListener('playbackStatusUpdate', (newStatus) => {
          if (!newStatus.isLoaded && 'error' in newStatus) {
            handleError(newStatus);
          }
        });
        
        return () => {
          subscription?.remove();
        };
      } catch (e) {
        console.log('[AudioPlayer] Could not add listener:', e);
      }
    }
  }, [player]);

  // Format time in mm:ss
  const formatTime = (seconds: number): string => {
    if (!seconds || isNaN(seconds)) return '0:00';
    const totalSeconds = Math.floor(seconds);
    const minutes = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  };

  // Determine loading state - show loading until we have duration
  const isLoading = !isReady || status?.isBuffering;
  
  // Check for errors
  const hasError = !url || loadError !== null;

  // Play/Pause toggle
  const togglePlayback = () => {
    console.log('[AudioPlayer] togglePlayback - playing:', status?.playing);
    if (!player) {
      console.log('[AudioPlayer] No player available');
      return;
    }
    
    try {
      if (status?.playing) {
        player.pause();
      } else {
        // If at end, seek to start first
        if (status?.currentTime >= status?.duration - 0.1) {
          player.seekTo(0);
        }
        player.play();
      }
    } catch (e) {
      console.error('[AudioPlayer] Playback error:', e);
    }
  };

  // Seek to position (slider gives value in seconds)
  const seekTo = async (value: number) => {
    console.log('[AudioPlayer] seekTo:', value);
    if (player) {
      try {
        await player.seekTo(value);
      } catch (e) {
        console.error('[AudioPlayer] Seek error:', e);
      }
    }
  };

  return (
    <View style={styles.container} testID="audio-player-container">
      {/* Title and artist */}
      {(title || artist) && (
        <View style={styles.metadata}>
          {title && <Text style={styles.title} numberOfLines={1}>{title}</Text>}
          {artist && <Text style={styles.artist} numberOfLines={1}>{artist}</Text>}
        </View>
      )}
      
      {/* Error state */}
      {hasError && (
        <View style={styles.errorContainer}>
          <Ionicons name="alert-circle" size={24} color="#ef4444" />
          <Text style={styles.errorText}>
            {loadError || 'No audio URL provided'}
          </Text>
        </View>
      )}
      
      {/* Controls */}
      <View style={styles.controls}>
        {/* Play/Pause button */}
        <Pressable 
          onPress={togglePlayback} 
          style={[styles.playButton, { backgroundColor: primaryColor }]}
          testID="audio-play-button"
        >
          {isLoading && !status?.playing ? (
            <ActivityIndicator color="#fff" size="small" />
          ) : (
            <Ionicons 
              name={status?.playing ? 'pause' : 'play'} 
              size={28} 
              color="#fff" 
            />
          )}
        </Pressable>
        
        {/* Progress section */}
        <View style={styles.progressSection}>
          {/* Time display */}
          <View style={styles.timeRow}>
            <Text style={styles.timeText} testID="audio-time-current">
              {formatTime(status?.currentTime || 0)}
            </Text>
            <Text style={styles.timeText} testID="audio-time-duration">
              {formatTime(status?.duration || 0)}
            </Text>
          </View>
          
          {/* Slider */}
          <Slider
            style={styles.slider}
            minimumValue={0}
            maximumValue={status?.duration || 1}
            value={status?.currentTime || 0}
            onSlidingComplete={seekTo}
            minimumTrackTintColor={primaryColor}
            maximumTrackTintColor="#e2e8f0"
            thumbTintColor={primaryColor}
          />
        </View>
      </View>
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
  errorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fef2f2',
    padding: 12,
    borderRadius: 8,
    marginBottom: 12,
  },
  errorText: {
    color: '#ef4444',
    marginLeft: 8,
    fontSize: 14,
  },
  controls: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  playButton: {
    width: 52,
    height: 52,
    borderRadius: 26,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  progressSection: {
    flex: 1,
  },
  timeRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 4,
  },
  timeText: {
    fontSize: 12,
    color: '#64748b',
  },
  slider: {
    width: '100%',
    height: 40,
  },
});
