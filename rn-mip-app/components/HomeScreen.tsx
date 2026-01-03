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

  // Navigate by label (looks up in menu) or directly by UUID
  // fallbackUrl: opens in browser if nothing else matches
  // directUuid: navigate directly to this UUID (for pages not in menu)
  const handleNavigate = (label: string, fallbackUrl?: string, directUuid?: string) => {
    const target = findMenuItemByLabel(label);
    const targetUuid = target?.page?.uuid || directUuid;
    
    if (targetUuid && targetUuid !== '__home__') {
      // Check if this UUID is in our bottom tabs
      const isTab = menu.some(item => item.page.uuid === targetUuid);
      
      if (isTab) {
        onSwitchTab(targetUuid);
        return;
      }

      // If not a tab, push to stack
      router.push(`/page/${targetUuid}`);
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

  // Quick Tasks: All items navigate in-app (no browser)
  // UUIDs from ticket 055: Chapters=pik8ysClOFGyllBY, Events=6ffa8qmIpJHM0C3r, 
  // Resources=uezb3178BtP3oGuU, Get Involved=3e56Ag4tc8SfnGAv
  const quickTasks = [
    {
      key: 'chapters',
      label: 'Find a Chapter',
      description: 'Connect with local firefighters',
      icon: '📍',
      onPress: () => handleNavigate('Chapters', undefined, 'pik8ysClOFGyllBY'),
      testID: 'home-quick-chapters',
    },
    {
      key: 'events',
      label: 'Upcoming Events',
      description: 'Retreats, trainings, & more',
      icon: '📅',
      onPress: () => handleNavigate('Events', undefined, '6ffa8qmIpJHM0C3r'),
      testID: 'home-quick-events',
    },
    {
      key: 'resources',
      label: 'Resources',
      description: 'PDFs, videos, & links',
      icon: '📚',
      onPress: () => handleNavigate('Resources', undefined, 'uezb3178BtP3oGuU'),
      testID: 'home-quick-resources',
    },
    {
      key: 'getinvolved',
      label: 'Get Involved',
      description: 'Outreach & volunteer',
      icon: '🤝',
      onPress: () => handleNavigate('Get Involved', undefined, '3e56Ag4tc8SfnGAv'),
      testID: 'home-quick-getinvolved',
    },
  ];

  // Get Connected: Items that open in browser
  const getConnected = [
    {
      key: 'prayer',
      label: 'Prayer Request',
      description: 'Submit a prayer request',
      icon: '🙏',
      onPress: () => handleNavigate('Prayer Request', 'https://ffci.fiveq.dev/prayer-request'),
      testID: 'home-connected-prayer',
    },
    {
      key: 'chaplain',
      label: 'Chaplain Request',
      description: 'Request chaplain support',
      icon: '✝️',
      onPress: () => handleNavigate('Chaplain Request', 'https://ffci.fiveq.dev/chaplain-request'),
      testID: 'home-connected-chaplain',
    },
    {
      key: 'donate',
      label: 'Donate',
      description: 'Support the ministry',
      icon: '💝',
      onPress: () => handleNavigate('Give', 'https://www.firefightersforchrist.org/donate'),
      testID: 'home-connected-donate',
    },
  ];

  // Featured items: Chaplain Resources (in-app) and Know God (browser)
  const featuredItems = [
    {
      key: 'chaplain-resources',
      title: 'Chaplain Resources',
      description: 'Downloadable tools and resources for chaplains',
      onPress: () => router.push('/page/PCLlwORLKbMnLPtN'),
      testID: 'home-featured-chaplain-resources',
    },
    {
      key: 'know-god',
      title: 'Do You Know God?',
      description: 'You were created to know God personally',
      onPress: () => Linking.openURL('https://www.harvest.org/know-god'),
      testID: 'home-featured-know-god',
    },
  ];

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
        Featured
      </Text>
      <View style={styles.featuredGrid}>
        {featuredItems.map((item) => (
          <TouchableOpacity
            key={item.key}
            style={styles.featuredCard}
            onPress={item.onPress}
            accessibilityLabel={item.title}
            testID={item.testID}
          >
            <View style={styles.featuredBadge}>
              <Text style={styles.featuredBadgeText}>Featured</Text>
            </View>
            <Text style={styles.featuredTitle}>{item.title}</Text>
            <Text style={styles.featuredDescription}>{item.description}</Text>
          </TouchableOpacity>
        ))}
      </View>

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
  featuredGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    marginBottom: 24,
  },
  featuredCard: {
    flexBasis: '48%',
    padding: 16,
    borderRadius: 12,
    backgroundColor: '#eff6ff',
    borderColor: '#bfdbfe',
    borderWidth: 1,
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

