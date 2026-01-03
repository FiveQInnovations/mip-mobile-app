import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ActivityIndicator } from 'react-native';
import { ApiError } from '../lib/api';
import { getConfig } from '../lib/config';

interface ErrorScreenProps {
  error: Error | string;
  onRetry: () => void;
  retrying?: boolean;
}

type ErrorType = 'network' | 'not-found' | 'server' | 'generic';

function getErrorType(error: Error | string): ErrorType {
  if (error instanceof ApiError) {
    if (error.status === 404) return 'not-found';
    if (error.status >= 500) return 'server';
  }
  if (typeof error === 'string' && error.includes('Network request failed')) {
    return 'network';
  }
  if (error instanceof TypeError && error.message.includes('Network')) {
    return 'network';
  }
  return 'generic';
}

interface ErrorConfig {
  icon: string;
  title: string;
  description: string;
}

function getErrorConfig(type: ErrorType): ErrorConfig {
  switch (type) {
    case 'network':
      return {
        icon: '📡',
        title: 'No Connection',
        description: 'Check your internet connection and try again.',
      };
    case 'not-found':
      return {
        icon: '🔍',
        title: 'Page Not Found',
        description: "The page you're looking for doesn't exist.",
      };
    case 'server':
      return {
        icon: '⚠️',
        title: 'Something Went Wrong',
        description: "We're having trouble connecting. Try again in a moment.",
      };
    default:
      return {
        icon: '❌',
        title: 'Unable to Load',
        description: 'There was a problem loading this content.',
      };
  }
}

export function ErrorScreen({ error, onRetry, retrying = false }: ErrorScreenProps) {
  const config = getConfig();
  const errorType = getErrorType(error);
  const errorConfig = getErrorConfig(errorType);

  return (
    <View style={styles.container}>
      <Text style={styles.icon}>{errorConfig.icon}</Text>
      <Text style={styles.title}>{errorConfig.title}</Text>
      <Text style={styles.description}>{errorConfig.description}</Text>
      <TouchableOpacity
        style={[styles.retryButton, { backgroundColor: config.primaryColor }]}
        onPress={onRetry}
        disabled={retrying}
        accessibilityLabel="Retry button"
        accessibilityRole="button"
      >
        {retrying ? (
          <ActivityIndicator size="small" color="#ffffff" />
        ) : (
          <Text style={styles.retryButtonText}>Retry</Text>
        )}
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
    backgroundColor: '#ffffff',
  },
  icon: {
    fontSize: 64,
    marginBottom: 24,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#0f172a',
    marginBottom: 12,
    textAlign: 'center',
  },
  description: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 32,
    paddingHorizontal: 16,
  },
  retryButton: {
    paddingHorizontal: 32,
    paddingVertical: 12,
    borderRadius: 8,
    minWidth: 120,
    alignItems: 'center',
    justifyContent: 'center',
  },
  retryButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
});
