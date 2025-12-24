import React from 'react';
import { View, Text, ScrollView, Image, StyleSheet, ActivityIndicator, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { getSiteData, SiteData } from '../lib/api';
import { getConfig } from '../lib/config';

export function HomeScreen() {
  const [siteData, setSiteData] = React.useState<SiteData | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);
  const config = getConfig();
  const router = useRouter();

  React.useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    try {
      setLoading(true);
      const data = await getSiteData();
      setSiteData(data);
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to load data');
      console.error('Error loading site data:', err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <View style={styles.container} accessibilityLabel="Loading screen">
        <ActivityIndicator size="large" color={config.primaryColor} />
        <Text accessibilityLabel="Loading text" style={styles.loadingText}>Loading...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.container}>
        <Text style={styles.errorText}>Error: {error}</Text>
        <Text style={styles.retryText} onPress={loadData}>
          Tap to retry
        </Text>
      </View>
    );
  }

  if (!siteData) {
    return null;
  }

  const { site_data, menu } = siteData;
  const logoUrl = site_data.logo;

  return (
    <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
      {/* Logo Section */}
      {logoUrl && (
        <View style={styles.logoSection}>
          <Image
            source={{ uri: logoUrl }}
            style={styles.logo}
            resizeMode="contain"
          />
          {site_data.title && (
            <Text style={styles.siteTitle}>{site_data.title}</Text>
          )}
        </View>
      )}

      {/* App Name */}
      <Text accessibilityLabel="App name" style={styles.appName}>{site_data.app_name || config.appName}</Text>

      {/* Menu Items */}
      <View style={styles.menuSection}>
        <Text testID="menu-section-title" style={styles.sectionTitle}>Menu</Text>
        {menu.map((item, index) => (
          <TouchableOpacity
            key={index}
            style={styles.menuItem}
            onPress={() => router.push(`/page/${item.page.uuid}`)}
            testID={`menu-item-${item.label.toLowerCase()}`}
          >
            <Text style={styles.menuLabel}>{item.label}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Homepage Type Info */}
      {config.homepageType && (
        <View style={styles.infoSection}>
          <Text style={styles.infoLabel}>Homepage Type:</Text>
          <Text style={styles.infoValue}>{config.homepageType}</Text>
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  scrollView: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  content: {
    padding: 20,
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
  errorText: {
    fontSize: 16,
    color: '#d32f2f',
    marginBottom: 10,
  },
  retryText: {
    fontSize: 16,
    color: '#1976d2',
    textDecorationLine: 'underline',
  },
  logoSection: {
    alignItems: 'center',
    marginBottom: 30,
    paddingVertical: 20,
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
  },
  logo: {
    width: 200,
    height: 120,
    marginBottom: 10,
  },
  siteTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#333',
  },
  appName: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 30,
    color: '#333',
  },
  menuSection: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 15,
    color: '#333',
  },
  menuItem: {
    padding: 15,
    backgroundColor: '#f9f9f9',
    borderRadius: 8,
    marginBottom: 10,
    minHeight: 44,
    justifyContent: 'center',
  },
  menuLabel: {
    fontSize: 18,
    fontWeight: '500',
    color: '#333',
  },
  infoSection: {
    padding: 15,
    backgroundColor: '#e3f2fd',
    borderRadius: 8,
  },
  infoLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1976d2',
    marginBottom: 5,
  },
  infoValue: {
    fontSize: 16,
    color: '#333',
  },
});

