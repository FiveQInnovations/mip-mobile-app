import React from 'react';
import { View, Text, ScrollView, Image, StyleSheet, ActivityIndicator, TouchableOpacity, Linking, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { SvgUri } from 'react-native-svg';
import { getSiteData, SiteData, MenuItem } from '../lib/api';
import { getConfig } from '../lib/config';
import { clearAllCache, logCacheStatus } from '../lib/pageCache';

interface HomeScreenProps {
  siteData: SiteData;
  onSwitchTab: (uuid: string) => void;
}

export function HomeScreen({ siteData, onSwitchTab }: HomeScreenProps) {
  const config = getConfig();
  const router = useRouter();
  const [cacheCleared, setCacheCleared] = React.useState(false);

  const { site_data, menu } = siteData;
  const logoUrl = site_data.logo
    ? site_data.logo.startsWith('http')
      ? site_data.logo
      : `${config.apiBaseUrl}${site_data.logo}`
    : null;

  const findMenuItemByLabel = (label: string) =>
    menu.find((item) => item.label?.toLowerCase() === label.toLowerCase());

  const handleNavigate = (label: string, fallbackUrl?: string) => {
    const target = findMenuItemByLabel(label);
    if (target?.page?.uuid && target.page.uuid !== '__home__') {
      // Check if this UUID is in our bottom tabs
      const isTab = menu.some(item => item.page.uuid === target.page.uuid);
      
      if (isTab) {
        onSwitchTab(target.page.uuid);
        return;
      }

      // If not a tab, push to stack
      router.push(`/page/${target.page.uuid}`);
      return;
    }
    if (target?.page?.url) {
      Linking.openURL(target.page.url);
      return;
    }
    if (fallbackUrl) {
      Linking.openURL(fallbackUrl);
    }
  };

  const quickTasks = [
    {
      key: 'prayer',
      label: 'Prayer Request',
      description: 'Submit a prayer request',
      icon: '🙏',
      onPress: () => handleNavigate('Prayer Request', 'https://ffci.fiveq.dev/prayer-request'),
      testID: 'home-quick-prayer',
    },
    {
      key: 'chaplain',
      label: 'Chaplain Request',
      description: 'Request chaplain support',
      icon: '✝️',
      onPress: () => handleNavigate('Chaplain Request', 'https://ffci.fiveq.dev/chaplain-request'),
      testID: 'home-quick-chaplain',
    },
    {
      key: 'resources',
      label: 'Resources',
      description: 'Browse PDFs and links',
      icon: '📚',
      onPress: () => handleNavigate('Resources'),
      testID: 'home-quick-resources',
    },
    {
      key: 'donate',
      label: 'Donate',
      description: 'Opens in browser',
      icon: '💝',
      onPress: () =>
        handleNavigate('Give', 'https://www.firefightersforchrist.org/donate'),
      testID: 'home-quick-donate',
    },
  ];

  const getConnected = [
    {
      key: 'chapters',
      label: 'Find a Chapter',
      description: 'Search chapters directory',
      icon: '📍',
      onPress: () => handleNavigate('Chapters'),
      testID: 'home-getconnected-chapters',
    },
    {
      key: 'events',
      label: 'Upcoming Events',
      description: 'View next 1–3 events',
      icon: '📅',
      onPress: () => handleNavigate('Events'),
      testID: 'home-getconnected-events',
    },
  ];

  const featured = {
    label: 'Featured',
    title: 'Resources',
    description: 'Featured resource links',
    onPress: () => handleNavigate('Resources'),
    testID: 'home-featured',
  };

  const isSvgLogo = logoUrl && logoUrl.endsWith('.svg');

  return (
    <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
      {/* Hero Section (kept from existing) */}
      {logoUrl && (
        <View style={styles.logoSection}>
          {isSvgLogo ? (
            <SvgUri
              uri={logoUrl}
              width={200}
              height={120}
              style={styles.logo}
            />
          ) : (
            <Image
              source={{ uri: logoUrl }}
              style={styles.logo}
              resizeMode="contain"
            />
          )}
          {site_data.title && (
            <Text style={styles.siteTitle}>{site_data.title}</Text>
          )}
        </View>
      )}

      <Text
        accessibilityLabel="Firefighters for Christ International"
        style={styles.appName}
        testID="home-hero-app-name"
      >
        Firefighters for Christ International
      </Text>

      <Text style={styles.helloWorld} testID="hello-world">
        9:46
      </Text>

      {/* Quick Tasks */}
      <Text style={styles.sectionHeader} testID="home-quick-heading">
        Quick Tasks
      </Text>
      <View style={styles.quickGrid}>
        {quickTasks.map((item) => (
          <TouchableOpacity
            key={item.key}
            style={styles.quickCard}
            onPress={item.onPress}
            accessibilityLabel={item.label}
            testID={item.testID}
          >
            <Text style={styles.quickIcon}>{item.icon}</Text>
            <Text style={styles.quickTitle}>{item.label}</Text>
            <Text style={styles.quickDescription}>{item.description}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Get Connected */}
      <Text style={styles.sectionHeader} testID="home-connected-heading">
        Get Connected
      </Text>
      <View style={styles.connectedList}>
        {getConnected.map((item) => (
          <TouchableOpacity
            key={item.key}
            style={styles.connectedRow}
            onPress={item.onPress}
            accessibilityLabel={item.label}
            testID={item.testID}
          >
            <View style={styles.connectedLeft}>
              <Text style={styles.connectedIcon}>{item.icon}</Text>
              <View>
                <Text style={styles.connectedTitle}>{item.label}</Text>
                <Text style={styles.connectedDescription}>{item.description}</Text>
              </View>
            </View>
            <Text style={styles.chevron}>›</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Featured */}
      <Text style={styles.sectionHeader} testID="home-featured-heading">
        {featured.label}
      </Text>
      <TouchableOpacity
        style={styles.featuredCard}
        onPress={featured.onPress}
        accessibilityLabel={`${featured.label} ${featured.title}`}
        testID={featured.testID}
      >
        <View style={styles.featuredBadge}>
          <Text style={styles.featuredBadgeText}>Featured</Text>
        </View>
        <Text style={styles.featuredTitle}>{featured.title}</Text>
        <Text style={styles.featuredDescription}>{featured.description}</Text>
      </TouchableOpacity>

      {/* Homepage Type Info */}
      {config.homepageType && (
        <View style={styles.infoSection}>
          <Text style={styles.infoLabel}>Homepage Type:</Text>
          <Text style={styles.infoValue}>{config.homepageType}</Text>
        </View>
      )}

      {/* Dev Tools - Temporary */}
      <View style={styles.devSection}>
        <Text style={styles.devSectionHeader}>🔧 Dev Tools (Temp)</Text>
        <TouchableOpacity
          style={styles.devButton}
          onPress={() => {
            clearAllCache();
            logCacheStatus();
            setCacheCleared(true);
            setTimeout(() => setCacheCleared(false), 3000);
            Alert.alert('Cache Cleared', 'All cached pages have been cleared. Reload app to test prefetching.');
          }}
          testID="dev-clear-cache"
        >
          <Text style={styles.devButtonText}>
            {cacheCleared ? '✓ Cache Cleared!' : '🗑️ Clear Cache'}
          </Text>
        </TouchableOpacity>
        {cacheCleared && (
          <Text style={styles.devMessage}>
            Cache cleared! Reload app (Cmd+R) to test prefetching.
          </Text>
        )}
      </View>
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
    marginBottom: 24,
    color: '#333',
  },
  helloWorld: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 24,
    color: '#2563eb',
  },
  sectionHeader: {
    fontSize: 20,
    fontWeight: '700',
    color: '#0f172a',
    marginBottom: 12,
  },
  quickGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    marginBottom: 24,
  },
  quickCard: {
    flexBasis: '48%',
    backgroundColor: '#ffffff',
    borderColor: '#e5e7eb',
    borderWidth: 1,
    borderRadius: 12,
    padding: 14,
    minHeight: 140,
    shadowColor: '#000',
    shadowOpacity: 0.04,
    shadowRadius: 4,
    shadowOffset: { width: 0, height: 2 },
    elevation: 2,
  },
  quickIcon: {
    fontSize: 26,
    marginBottom: 10,
  },
  quickTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#0f172a',
    marginBottom: 6,
  },
  quickDescription: {
    fontSize: 13,
    color: '#475569',
  },
  connectedList: {
    marginBottom: 24,
  },
  connectedRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 14,
    paddingHorizontal: 12,
    borderColor: '#e5e7eb',
    borderWidth: 1,
    borderRadius: 12,
    marginBottom: 12,
    backgroundColor: '#ffffff',
  },
  connectedLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    flexShrink: 1,
  },
  connectedIcon: {
    fontSize: 22,
  },
  connectedTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#0f172a',
  },
  connectedDescription: {
    fontSize: 13,
    color: '#475569',
    marginTop: 2,
  },
  chevron: {
    fontSize: 20,
    color: '#94a3b8',
  },
  featuredCard: {
    padding: 16,
    borderRadius: 12,
    backgroundColor: '#eff6ff',
    borderColor: '#bfdbfe',
    borderWidth: 1,
    marginBottom: 24,
  },
  featuredBadge: {
    alignSelf: 'flex-start',
    backgroundColor: '#2563eb',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 999,
    marginBottom: 10,
  },
  featuredBadgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '700',
  },
  featuredTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#0f172a',
    marginBottom: 6,
  },
  featuredDescription: {
    fontSize: 14,
    color: '#475569',
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
  devSection: {
    marginTop: 24,
    padding: 16,
    backgroundColor: '#fff7ed',
    borderColor: '#fed7aa',
    borderWidth: 2,
    borderRadius: 12,
    borderStyle: 'dashed',
  },
  devSectionHeader: {
    fontSize: 14,
    fontWeight: '700',
    color: '#9a3412',
    marginBottom: 12,
  },
  devButton: {
    backgroundColor: '#dc2626',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
    alignItems: 'center',
  },
  devButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  devMessage: {
    marginTop: 8,
    fontSize: 12,
    color: '#9a3412',
    fontStyle: 'italic',
  },
});

