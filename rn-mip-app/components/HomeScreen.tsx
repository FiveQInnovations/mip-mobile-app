import React from 'react';
import { View, Text, ScrollView, Image, StyleSheet, ActivityIndicator, TouchableOpacity, Linking, Alert, Dimensions, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import { SvgUri } from 'react-native-svg';
import { getSiteData, SiteData, MenuItem } from '../lib/api';
import { getConfig } from '../lib/config';
import { clearAllCache, logCacheStatus } from '../lib/pageCache';
import { ContentCard } from './ContentCard';
import Ionicons from '@expo/vector-icons/Ionicons';

interface HomeScreenProps {
  siteData: SiteData;
  onSwitchTab: (uuid: string) => void;
}

// Custom Header Component
function CustomHeader({ onSearch, onProfile }: { onSearch: () => void, onProfile: () => void }) {
  return (
    <View style={styles.header}>
      <View style={styles.headerLeft}>
        <Image 
          source={require('../assets/adaptive-icon.png')} 
          style={styles.headerLogo} 
          resizeMode="contain"
        />
        <Text style={styles.headerTitle}>FFC</Text>
      </View>
      <View style={styles.headerRight}>
        <TouchableOpacity onPress={onSearch} style={styles.headerButton}>
          <Ionicons name="search-outline" size={24} color="#0f172a" />
        </TouchableOpacity>
        <TouchableOpacity onPress={onProfile} style={styles.headerButton}>
          <Ionicons name="person-circle-outline" size={26} color="#0f172a" />
        </TouchableOpacity>
      </View>
    </View>
  );
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

  // Calculate responsive logo size (85% of screen width, max 400px, min 280px)
  const screenWidth = Dimensions.get('window').width;
  const logoWidth = Math.min(Math.max(screenWidth * 0.85, 280), 400);
  const logoHeight = logoWidth * 0.6; // Maintain 5:3 aspect ratio (200:120)

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

  // Quick Tasks mapped to card layout
  // Using generic placeholder images (via Picsum) since direct site URLs are 404ing
  const quickTasks = [
    {
      key: 'about-us',
      label: 'About Us',
      description: 'Learn about the history of the FFC Ministry!',
      imageUrl: 'https://picsum.photos/seed/about/800/450', 
      onPress: () => handleNavigate('About', undefined, 'about-uuid-placeholder'), // Need real UUID
      testID: 'home-card-about',
    },
    {
      key: 'believe',
      label: 'What We Believe',
      description: 'FFC Core Values, Doctrine, Principles, Policies, Focus & Goals...',
      imageUrl: 'https://picsum.photos/seed/believe/800/450',
      onPress: () => handleNavigate('What We Believe', undefined, 'believe-uuid-placeholder'), // Need real UUID
      testID: 'home-card-believe',
    },
    {
      key: 'peace',
      label: 'Peace With God',
      description: 'Do you know God? Take the steps here',
      imageUrl: 'https://picsum.photos/seed/peace/800/450',
      onPress: () => Linking.openURL('https://www.harvest.org/know-god'),
      testID: 'home-card-peace',
    },
  ];

  // Featured items
  const featuredItems = [
    {
      key: 'chaplain-resources',
      title: 'Chaplain Resources',
      description: 'Downloadable tools and resources for chaplains',
      imageUrl: 'https://picsum.photos/seed/chaplain/800/450',
      onPress: () => router.push('/page/PCLlwORLKbMnLPtN'),
      testID: 'home-featured-chaplain-resources',
    },
    {
      key: 'events',
      title: 'Upcoming Events',
      description: 'Retreats, trainings, & more',
      imageUrl: 'https://picsum.photos/seed/events/800/450',
      onPress: () => handleNavigate('Events', undefined, '6ffa8qmIpJHM0C3r'),
      testID: 'home-featured-events',
    }
  ];

  const isSvgLogo = logoUrl && logoUrl.endsWith('.svg');

  return (
    <View style={styles.container}>
      <CustomHeader 
        onSearch={() => router.push('/search')}
        onProfile={() => Alert.alert('Profile', 'User profile coming soon')}
      />
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
        {/* Hero Section */}
        <View style={styles.logoSection}>
          {logoUrl && (
            isSvgLogo ? (
              <SvgUri
                uri={logoUrl}
                width={logoWidth}
                height={logoHeight}
                style={styles.logo}
              />
            ) : (
              <Image
                source={{ uri: logoUrl }}
                style={[styles.logo, { width: logoWidth, height: logoHeight }]}
                resizeMode="contain"
              />
            )
          )}
        </View>

        {/* Horizontal Scroll for Main Cards */}
        <ScrollView 
          horizontal 
          showsHorizontalScrollIndicator={false}
          style={styles.horizontalScroll}
          contentContainerStyle={styles.horizontalScrollContent}
        >
          {quickTasks.map((item) => (
            <ContentCard
              key={item.key}
              title={item.label}
              description={item.description}
              imageUrl={item.imageUrl}
              onPress={item.onPress}
              style={styles.carouselCard}
              testID={item.testID}
            />
          ))}
        </ScrollView>

        {/* Featured Section */}
        <Text style={styles.sectionHeader} testID="home-featured-heading">
          Featured
        </Text>
        <View style={styles.verticalList}>
          {featuredItems.map((item) => (
            <ContentCard
              key={item.key}
              title={item.title}
              description={item.description}
              imageUrl={item.imageUrl}
              onPress={item.onPress}
              style={styles.fullWidthCard}
              testID={item.testID}
              badgeText="Featured"
            />
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
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  headerLogo: {
    width: 24,
    height: 24,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#0f172a',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
  },
  headerButton: {
    padding: 4,
  },
  scrollView: {
    flex: 1,
  },
  content: {
    paddingBottom: 40,
  },
  logoSection: {
    alignItems: 'center',
    paddingVertical: 30,
    paddingHorizontal: 20,
    backgroundColor: '#f8fafc',
    marginBottom: 20,
  },
  logo: {
    marginBottom: 0,
  },
  horizontalScroll: {
    marginBottom: 24,
  },
  horizontalScrollContent: {
    paddingHorizontal: 16,
    paddingRight: 8, // extra padding for last item
  },
  carouselCard: {
    width: 280,
    marginRight: 16,
    // Add border to distinguish from white background
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  sectionHeader: {
    fontSize: 20,
    fontWeight: '700',
    color: '#0f172a',
    marginBottom: 16,
    paddingHorizontal: 16,
  },
  verticalList: {
    paddingHorizontal: 16,
    gap: 16,
  },
  fullWidthCard: {
    width: '100%',
    marginBottom: 0, // Handled by gap
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  devSection: {
    marginTop: 32,
    marginHorizontal: 16,
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
