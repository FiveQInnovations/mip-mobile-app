/**
 * TabScreen - Renders page content within TabNavigator context.
 * 
 * Used by: TabNavigator for main tab content
 * Navigation: Internal stack via navigateToPage() - preserves tab context
 * 
 * Keep feature parity with PageScreen.tsx for collection/audio rendering.
 * Shared components: CollectionItemList, AudioPlayer
 */
import React from 'react';
import { View, Text, ScrollView, Image, StyleSheet, ActivityIndicator, TouchableOpacity, Pressable } from 'react-native';
import { getPageWithCache, PageData } from '../lib/api';
import { getConfig } from '../lib/config';
import { HTMLContentRenderer } from './HTMLContentRenderer';
import { hasCachedPage, clearCachedPage } from '../lib/pageCache';
import { ErrorScreen } from './ErrorScreen';
import { SplashScreen } from './SplashScreen';
import Ionicons from '@expo/vector-icons/Ionicons';
import { AudioPlayer } from './AudioPlayer';
import { CollectionItemList } from './CollectionItemList';

interface TabScreenProps {
  uuid: string;
}

export function TabScreen({ uuid }: TabScreenProps) {
  const [pageStack, setPageStack] = React.useState<string[]>([uuid]);
  const [currentPageData, setCurrentPageData] = React.useState<PageData | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [refreshing, setRefreshing] = React.useState(false);
  const [error, setError] = React.useState<Error | null>(null);
  const config = getConfig();

  const currentUuid = pageStack[pageStack.length - 1];
  const canGoBack = pageStack.length > 1;

  React.useEffect(() => {
    const mountTime = Date.now();
    const hasCache = hasCachedPage(currentUuid);
    console.log(`[TabScreen] Component mounted at ${mountTime} with UUID: ${uuid}, hasCache: ${hasCache}, loading state: ${loading}`);
    return () => {
      const unmountTime = Date.now();
      console.log(`[TabScreen] Component unmounting at ${unmountTime} for UUID: ${uuid}`);
    };
  }, []);

  React.useEffect(() => {
    const timestamp = Date.now();
    console.log(`[TabScreen] useEffect triggered at ${timestamp}, currentUuid: ${currentUuid}`);
    if (currentUuid) {
      loadPage();
    }
  }, [currentUuid]);

  async function loadPage() {
    const startTime = Date.now();
    console.log(`[TabScreen] loadPage() called at ${startTime} for UUID: ${currentUuid}`);
    
    // Check if we have cached data
    const hasCache = hasCachedPage(currentUuid);
    
    try {
      if (!hasCache) {
        // No cache - show loading indicator
        console.log(`[TabScreen] No cache, setting loading=true at ${Date.now()}`);
        setLoading(true);
      } else {
        // We have cache - it will be returned immediately, but set refreshing state
        console.log(`[TabScreen] Cache available, will show cached content immediately`);
        setRefreshing(true);
      }

      const apiStartTime = Date.now();
      console.log(`[TabScreen] Calling getPageWithCache at ${apiStartTime}`);
      const { data, fromCache, refreshPromise } = await getPageWithCache(currentUuid);
      const apiEndTime = Date.now();
      const apiDuration = apiEndTime - apiStartTime;
      
      console.log(`[TabScreen] getPageWithCache completed at ${apiEndTime}, duration: ${apiDuration}ms, fromCache: ${fromCache}`);
      
      setCurrentPageData(data);
      setError(null);
      console.log(`[TabScreen] Page data set, title: ${data.title || 'N/A'}`);
      
      // If data came from cache, it was instant - no loading needed
      if (fromCache) {
        console.log(`[TabScreen] Data from cache - instant display (${apiDuration}ms), background refresh in progress`);
        setLoading(false);
        setRefreshing(true);
        
        // Wait for background refresh to complete and update UI
        if (refreshPromise) {
          refreshPromise
            .then(freshData => {
              const refreshCompleteTime = Date.now();
              const totalTime = refreshCompleteTime - apiStartTime;
              console.log(`[TabScreen] Background refresh completed at ${refreshCompleteTime}, total time: ${totalTime}ms`);
              setCurrentPageData(freshData);
              setRefreshing(false);
            })
            .catch(err => {
              console.error(`[TabScreen] Background refresh error:`, err);
              setRefreshing(false);
            });
        }
      } else {
        // Fresh data fetched - done loading
        setLoading(false);
        setRefreshing(false);
      }
    } catch (err: any) {
      setError(err instanceof Error ? err : new Error(err.message || 'Failed to load page'));
      console.error(`[TabScreen] Error loading page at ${Date.now()}:`, err);
      setLoading(false);
      setRefreshing(false);
    }
  }


  const navigateToPage = (pageUuid: string) => {
    setPageStack(prev => [...prev, pageUuid]);
  };

  const goBack = () => {
    setPageStack(prev => {
      if (prev.length > 1) {
        return prev.slice(0, -1);
      }
      return prev;
    });
  };

  const handleManualRefresh = () => {
    console.log(`[TabScreen] Manual refresh triggered for UUID: ${currentUuid}`);
    clearCachedPage(currentUuid);
    loadPage();
  };

  if (loading) {
    return <SplashScreen />;
  }

  if (error) {
    return <ErrorScreen error={error} onRetry={loadPage} retrying={loading || refreshing} />;
  }

  if (!currentPageData) {
    return null;
  }

  const pageType = currentPageData.page_type || currentPageData.type || 'content';

  // Check if this is an audio item with audio content
  const isAudioItem = pageType === 'collection-item' && currentPageData.type === 'audio';
  const audioUrl = currentPageData.data?.content?.audio_url;
  const audioTitle = currentPageData.data?.content?.audio_name || currentPageData.title;
  const audioArtist = currentPageData.data?.content?.audio_credit;

  // Dynamic styles that use config colors
  const dynamicStyles = {
    headerContainer: {
      backgroundColor: config.primaryColor,
      paddingTop: 50, // Status bar area
      paddingBottom: 16,
      paddingHorizontal: 16,
      flexDirection: 'row' as const,
      alignItems: 'center',
      shadowColor: '#000',
      shadowOpacity: 0.1,
      shadowRadius: 4,
      shadowOffset: { width: 0, height: 2 },
      elevation: 4,
      zIndex: 10,
    },
    headerTitle: {
      color: '#ffffff',
      fontSize: 18,
      fontWeight: '700' as const,
      flex: 1,
      marginLeft: 12,
    },
    backButton: {
      padding: 8,
      marginRight: 4,
      borderRadius: 20,
      backgroundColor: 'rgba(255,255,255,0.2)',
    },
    backButtonText: {
      color: '#ffffff',
      fontSize: 16,
      fontWeight: '600' as const,
    },
  };

  return (
    <View style={styles.container}>
      {/* Refresh indicator - thin progress bar at top */}
      {refreshing && (
        <View style={styles.refreshIndicatorContainer}>
          <View style={[styles.refreshIndicatorBar, { backgroundColor: config.primaryColor }]} />
        </View>
      )}

      {/* Modern Header */}
      {canGoBack && (
        <View style={dynamicStyles.headerContainer}>
          <TouchableOpacity 
            style={dynamicStyles.backButton} 
            onPress={goBack}
            accessibilityLabel="Go back"
            accessibilityRole="button"
          >
            <Text style={dynamicStyles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={dynamicStyles.headerTitle} numberOfLines={1}>
            {currentPageData.title}
          </Text>
          <View style={styles.headerRightActions}>
            {refreshing && (
              <ActivityIndicator 
                size="small" 
                color="#ffffff" 
                style={styles.headerRefreshSpinner}
                accessibilityLabel="Refreshing content"
              />
            )}
            {/* Dev tool: Manual refresh button */}
            <TouchableOpacity
              onPress={handleManualRefresh}
              style={styles.devRefreshButton}
              accessibilityLabel="Refresh page"
              accessibilityRole="button"
              testID="dev-refresh-button"
            >
              <Ionicons name="refresh" size={18} color="#ffffff" />
            </TouchableOpacity>
          </View>
        </View>
      )}

      {/* Refresh indicator for non-header pages */}
      {!canGoBack && refreshing && (
        <View style={styles.refreshIndicatorContainer}>
          <View style={[styles.refreshIndicatorBar, { backgroundColor: config.primaryColor }]} />
        </View>
      )}

      <ScrollView 
        style={styles.scrollView} 
        contentContainerStyle={styles.content}
        keyboardShouldPersistTaps="handled"
      >
        {/* Cover Image */}
        {currentPageData.cover && (
          <Image
            source={{ uri: currentPageData.cover }}
            style={styles.cover}
            resizeMode="cover"
          />
        )}

        {/* Page Title - Only show if not in header (or always show large title for context?) */}
        {/* We keep the large title for context, header title is for navigation context when scrolled or deep */}
        {!canGoBack && (
          <View style={styles.titleHeaderContainer}>
            <View style={{ height: 4, backgroundColor: config.primaryColor }} />
            {refreshing && (
              <View style={styles.titleRefreshIndicator}>
                <ActivityIndicator 
                  size="small" 
                  color={config.primaryColor}
                  accessibilityLabel="Refreshing content"
                />
              </View>
            )}
          </View>
        )}
        <Text style={[styles.title, { color: config.textColor || '#0f172a' }]}>{currentPageData.title}</Text>

        {/* Page Content - Render HTML */}
        {pageType === 'content' && currentPageData.page_content && (
          <HTMLContentRenderer html={currentPageData.page_content} onNavigate={navigateToPage} />
        )}

        {/* Audio Player for audio items */}
        {isAudioItem && audioUrl && (
          <View style={{ paddingHorizontal: 16 }}>
            <AudioPlayer 
              url={audioUrl}
              title={audioTitle}
              artist={audioArtist}
            />
          </View>
        )}

        {/* Collection Item Type - Render HTML */}
        {pageType === 'collection-item' && currentPageData.data?.page_content && (
          <HTMLContentRenderer html={currentPageData.data.page_content} onNavigate={navigateToPage} />
        )}

        {/* Collection Type - Show children */}
        {pageType === 'collection' && (
          <View style={styles.contentSection}>
            <CollectionItemList 
              children={currentPageData.children || []}
              onNavigate={navigateToPage}
              primaryColor={config.primaryColor}
              textColor={config.textColor || '#0f172a'}
            />
          </View>
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  scrollView: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  content: {
    paddingBottom: 20,
  },
  backButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 12,
    backgroundColor: '#f8fafc',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
    gap: 4,
  },
  backButtonIcon: {
    fontSize: 28,
    fontWeight: '300',
    marginTop: -2,
  },
  backButtonText: {
    fontSize: 16,
    color: '#475569',
    fontWeight: '500',
  },
  cover: {
    width: '100%',
    aspectRatio: 16 / 9,
    backgroundColor: '#f1f5f9',
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
    paddingHorizontal: 16,
    paddingTop: 20,
    paddingBottom: 8,
    letterSpacing: -0.5,
  },
  contentSection: {
    paddingHorizontal: 16,
    paddingTop: 16,
  },
  refreshIndicatorContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 3,
    zIndex: 1000,
    overflow: 'hidden',
  },
  refreshIndicatorBar: {
    height: '100%',
    width: '100%',
  },
  headerRefreshSpinner: {
    marginRight: 8,
  },
  headerRightActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  devRefreshButton: {
    padding: 6,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.2)',
    marginLeft: 4,
  },
  titleHeaderContainer: {
    position: 'relative',
  },
  titleRefreshIndicator: {
    position: 'absolute',
    top: 8,
    right: 16,
    zIndex: 10,
  },
});
