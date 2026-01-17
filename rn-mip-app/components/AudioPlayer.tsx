import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, StyleSheet, Pressable, ActivityIndicator } from 'react-native';
import { Audio, AVPlaybackStatus } from 'expo-av';
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
  
  const [sound, setSound] = useState<Audio.Sound | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [duration, setDuration] = useState(0);
  const [position, setPosition] = useState(0);
  const [error, setError] = useState<string | null>(null);

  // Format time in mm:ss
  const formatTime = (millis: number): string => {
    const totalSeconds = Math.floor(millis / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  // Load audio
  const loadAudio = useCallback(async () => {
    if (!url) return;
    
    setIsLoading(true);
    setError(null);
    
    try {
      // Unload existing sound
      if (sound) {
        await sound.unloadAsync();
      }
      
      // Configure audio mode
      await Audio.setAudioModeAsync({
        playsInSilentModeIOS: true,
        staysActiveInBackground: false,
      });
      
      // Load new sound
      const { sound: newSound } = await Audio.Sound.createAsync(
        { uri: url },
        { shouldPlay: false },
        onPlaybackStatusUpdate
      );
      
      setSound(newSound);
    } catch (err) {
      console.error('[AudioPlayer] Error loading audio:', err);
      setError('Failed to load audio');
    } finally {
      setIsLoading(false);
    }
  }, [url]);

  // Playback status update handler
  const onPlaybackStatusUpdate = (status: AVPlaybackStatus) => {
    if (!status.isLoaded) {
      if (status.error) {
        console.error('[AudioPlayer] Playback error:', status.error);
        setError('Playback error');
      }
      return;
    }
    
    setIsPlaying(status.isPlaying);
    setDuration(status.durationMillis || 0);
    setPosition(status.positionMillis || 0);
  };

  // Play/Pause toggle
  const togglePlayback = async () => {
    if (!sound) {
      await loadAudio();
      return;
    }
    
    if (isPlaying) {
      await sound.pauseAsync();
    } else {
      await sound.playAsync();
    }
  };

  // Seek to position
  const seekTo = async (value: number) => {
    if (sound) {
      await sound.setPositionAsync(value);
    }
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (sound) {
        sound.unloadAsync();
      }
    };
  }, [sound]);

  // Load audio when URL changes
  useEffect(() => {
    if (url) {
      loadAudio();
    }
  }, [url, loadAudio]);

  return (
    <View style={styles.container}>
      {/* Title and artist */}
      {(title || artist) && (
        <View style={styles.metadata}>
          {title && <Text style={styles.title} numberOfLines={1}>{title}</Text>}
          {artist && <Text style={styles.artist} numberOfLines={1}>{artist}</Text>}
        </View>
      )}
      
      {/* Error state */}
      {error && (
        <View style={styles.errorContainer}>
          <Ionicons name="alert-circle" size={24} color="#ef4444" />
          <Text style={styles.errorText}>{error}</Text>
        </View>
      )}
      
      {/* Controls */}
      <View style={styles.controls}>
        {/* Play/Pause button */}
        <Pressable 
          onPress={togglePlayback} 
          style={[styles.playButton, { backgroundColor: primaryColor }]}
          disabled={isLoading}
        >
          {isLoading ? (
            <ActivityIndicator color="#fff" size="small" />
          ) : (
            <Ionicons 
              name={isPlaying ? 'pause' : 'play'} 
              size={28} 
              color="#fff" 
            />
          )}
        </Pressable>
        
        {/* Progress section */}
        <View style={styles.progressSection}>
          {/* Time display */}
          <View style={styles.timeRow}>
            <Text style={styles.timeText}>{formatTime(position)}</Text>
            <Text style={styles.timeText}>{formatTime(duration)}</Text>
          </View>
          
          {/* Slider */}
          <Slider
            style={styles.slider}
            minimumValue={0}
            maximumValue={duration || 1}
            value={position}
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
