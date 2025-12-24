import React from 'react';
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';
import { getConfig } from '../lib/config';

export function SplashScreen() {
  const config = getConfig();

  return (
    <View style={styles.container}>
      <Text style={styles.appName}>{config.appName}</Text>
      <ActivityIndicator size="large" color={config.primaryColor} style={styles.loader} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  logo: {
    width: 200,
    height: 120,
    marginBottom: 20,
  },
  appName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  loader: {
    marginTop: 20,
  },
});

