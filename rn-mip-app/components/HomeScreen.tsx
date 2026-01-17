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
function CustomHeader({ onSearch }: { onSearch: () => void }) {
  return (
    <View style={styles.header}>
      <View style={styles.headerLeft}>
        <Image 
          source={require('../assets/adaptive-icon.png')} 
          style={styles.headerLogo} 
          resizeMode="contain"
          accessibilityLabel="Firefighters for Christ Logo"
        />
      </View>
      <View style={styles.headerRight}>
        <TouchableOpacity onPress={onSearch} style={styles.headerButton} testID="search-outline">
          <Ionicons name="search-outline" size={24} color="#0f172a" />
        </TouchableOpacity>
      </View>
    </View>
  );
}

export function HomeScreen({ siteData, onSwitchTab }: HomeScreenProps) {
  const config = getConfig();
  const router = useRouter();
  const [cacheCleared, setCacheCleared] = React.useState(false);

  // State for scroll indicators
  const [canScrollLeft, setCanScrollLeft] = React.useState(false);
  const [canScrollRight, setCanScrollRight] = React.useState(false);
  const scrollViewRef = React.useRef<ScrollView>(null);
  const contentWidth = React.useRef(0);
  const containerWidth = React.useRef(0);
  const currentScrollX = React.useRef(0);

  const { site_data, menu } = siteData;
  // Use API logo if available, otherwise fall back to bundled asset
  const logoUrl = site_data.logo
    ? site_data.logo.startsWith('http')
      ? site_data.logo
      : `${config.apiBaseUrl}${site_data.logo}`
    : null;
  
  // Fallback to local asset if API doesn't provide logo
  const fallbackLogoPath = require('../assets/ffci-logo.svg');

  // Calculate responsive logo size (60% of screen width, max 280px, min 200px)
  const screenWidth = Dimensions.get('window').width;
  const logoWidth = Math.min(Math.max(screenWidth * 0.60, 200), 280);
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

  // Default Quick Tasks (fallback when API config is empty)
  const DEFAULT_QUICK_TASKS = [
    {
      key: 'about-us',
      label: 'About Us',
      description: 'Learn about the history of the FFC Ministry!',
      imageUrl: 'https://picsum.photos/seed/about/800/450', 
      onPress: () => handleNavigate('About', undefined, 'xhZj4ejQ65bRhrJg'),
      testID: 'home-card-about',
    },
    {
      key: 'believe',
      label: 'What We Believe',
      description: 'FFC Core Values, Doctrine, Principles, Policies, Focus & Goals...',
      imageUrl: 'https://picsum.photos/seed/believe/800/450',
      onPress: () => handleNavigate('What We Believe', undefined, 'fZdDBgMUDK3ZiRID'),
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

  // Default Featured Items (fallback when API config is empty)
  const DEFAULT_FEATURED_ITEMS = [
    {
      key: 'chaplain-resources',
      title: 'Chaplain Resources',
      description: 'Downloadable tools and resources for chaplains',
      imageUrl: 'https://picsum.photos/seed/chaplain/800/450',
      badgeText: 'Featured',
      onPress: () => router.push('/page/PCLlwORLKbMnLPtN'),
      testID: 'home-featured-chaplain-resources',
    },
    {
      key: 'events',
      title: 'Upcoming Events',
      description: 'Retreats, trainings, & more',
      imageUrl: 'https://picsum.photos/seed/events/800/450',
      badgeText: 'Featured',
      onPress: () => handleNavigate('Events', undefined, '6ffa8qmIpJHM0C3r'),
      testID: 'home-featured-events',
    }
  ];

  // Use API data with fallback to hardcoded defaults
  const quickTasksFromApi = site_data.homepage_quick_tasks || [];
  const quickTasks = quickTasksFromApi.length > 0 
    ? quickTasksFromApi.map((item, idx) => ({
        key: `api-quick-${idx}`,
        label: item.label,
        description: item.description,
        imageUrl: item.image_url || 'https://picsum.photos/seed/placeholder/800/450',
        onPress: () => item.external_url 
          ? Linking.openURL(item.external_url)
          : handleNavigate('', undefined, item.uuid || undefined),
        testID: `home-card-api-${idx}`,
      }))
    : DEFAULT_QUICK_TASKS;

  // Use API data with fallback to hardcoded defaults
  const featuredItemsFromApi = site_data.homepage_featured || [];
  const featuredItems = featuredItemsFromApi.length > 0
    ? featuredItemsFromApi.map((item, idx) => ({
        key: `api-featured-${idx}`,
        title: item.title,
        description: item.description,
        imageUrl: item.image_url || 'https://picsum.photos/seed/placeholder/800/450',
        badgeText: item.badge_text || 'Featured',
        onPress: () => item.external_url
          ? Linking.openURL(item.external_url)
          : handleNavigate('', undefined, item.uuid || undefined),
        testID: `home-featured-api-${idx}`,
      }))
    : DEFAULT_FEATURED_ITEMS;

  const isSvgLogo = logoUrl && logoUrl.endsWith('.svg');

  // Check if scroll indicators should be visible
  const checkScrollBounds = (offsetX: number) => {
    // Only check bounds when both dimensions are set
    if (contentWidth.current === 0 || containerWidth.current === 0) {
      return;
    }
    const maxScroll = contentWidth.current - containerWidth.current;
    setCanScrollLeft(offsetX > 5); // Show left arrow if scrolled more than 5px from start
    setCanScrollRight(offsetX < maxScroll - 5); // Show right arrow if not at end
  };

  // Handle scroll event
  const handleScroll = (event: any) => {
    const offsetX = event.nativeEvent.contentOffset.x;
    currentScrollX.current = offsetX;
    checkScrollBounds(offsetX);
  };

  // Handle content size change
  const handleContentSizeChange = (width: number) => {
    contentWidth.current = width;
    if (containerWidth.current > 0) {
      // Initial check - content is scrollable but we're at the start
      setCanScrollRight(width > containerWidth.current);
      setCanScrollLeft(false); // At initial position, no left scroll
    }
  };

  // Handle layout change
  const handleLayout = (event: any) => {
    containerWidth.current = event.nativeEvent.layout.width;
    if (contentWidth.current > 0) {
      setCanScrollRight(contentWidth.current > containerWidth.current);
      setCanScrollLeft(false); // At initial position, no left scroll
    }
  };

  return (
    <View style={styles.container}>
      <CustomHeader 
        onSearch={() => router.push('/search')}
      />
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
        {/* Hero Section */}
        <View style={styles.logoSection}>
          {logoUrl ? (
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
          ) : (
            <Image
              source={fallbackLogoPath}
              style={[styles.logo, { width: logoWidth, height: logoHeight }]}
              resizeMode="contain"
              accessibilityLabel="Firefighters for Christ Logo"
            />
          )}
        </View>

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
              badgeText={item.badgeText}
            />
          ))}
        </View>

        {/* Resources Section */}
        <Text style={styles.sectionHeader}>
          Resources
        </Text>
        <View style={styles.scrollContainer}>
          <ScrollView 
            ref={scrollViewRef}
            horizontal 
            showsHorizontalScrollIndicator={false}
            style={styles.horizontalScroll}
            contentContainerStyle={styles.horizontalScrollContent}
            onScroll={handleScroll}
            scrollEventThrottle={16}
            onContentSizeChange={handleContentSizeChange}
            onLayout={handleLayout}
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
          
          {/* Left Arrow */}
          {canScrollLeft && (
            <TouchableOpacity 
              style={[styles.scrollArrow, styles.scrollArrowLeft]}
              onPress={() => {
                const cardWidth = 280 + 16; // card width + margin
                const newX = Math.max(0, currentScrollX.current - cardWidth);
                scrollViewRef.current?.scrollTo({ x: newX, animated: true });
              }}
              testID="scroll-arrow-left"
            >
              <Ionicons name="chevron-back" size={24} color="#0f172a" />
            </TouchableOpacity>
          )}
          
          {/* Right Arrow */}
          {canScrollRight && (
            <TouchableOpacity 
              style={[styles.scrollArrow, styles.scrollArrowRight]}
              onPress={() => {
                const cardWidth = 280 + 16; // card width + margin
                const maxScroll = contentWidth.current - containerWidth.current;
                const newX = Math.min(maxScroll, currentScrollX.current + cardWidth);
                scrollViewRef.current?.scrollTo({ x: newX, animated: true });
              }}
              testID="scroll-arrow-right"
            >
              <Ionicons name="chevron-forward" size={24} color="#0f172a" />
            </TouchableOpacity>
          )}
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
  },
  headerLogo: {
    width: 32,
    height: 32,
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
    paddingVertical: 20,
    paddingHorizontal: 20,
    backgroundColor: '#f8fafc',
    marginBottom: 12,
  },
  logo: {
    marginBottom: 0,
  },
  scrollContainer: {
    position: 'relative',
    marginBottom: 24,
    minHeight: 280, // Approximate card height for arrow positioning
  },
  horizontalScroll: {
    // marginBottom moved to scrollContainer
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
  scrollArrow: {
    position: 'absolute',
    top: 100, // Position near the middle of the card (card image is ~158px)
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: 'rgba(0, 0, 0, 0.1)',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 6,
    elevation: 4,
    zIndex: 10,
  },
  scrollArrowLeft: {
    left: 8,
  },
  scrollArrowRight: {
    right: 8,
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
