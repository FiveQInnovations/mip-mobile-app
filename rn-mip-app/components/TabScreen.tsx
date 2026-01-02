import React from 'react';
import { View, Text, ScrollView, Image, StyleSheet, ActivityIndicator, TouchableOpacity } from 'react-native';
import { getPageWithCache, PageData } from '../lib/api';
import { getConfig } from '../lib/config';
import { HTMLContentRenderer } from './HTMLContentRenderer';
import { hasCachedPage } from '../lib/pageCache';

interface TabScreenProps {
  uuid: string;
}

export function TabScreen({ uuid }: TabScreenProps) {
  const [pageStack, setPageStack] = React.useState<string[]>([uuid]);
  const [currentPageData, setCurrentPageData] = React.useState<PageData | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [refreshing, setRefreshing] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);
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
      setError(err.message || 'Failed to load page');
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
        <Text style={styles.retryText} onPress={loadPage}>
          Tap to retry
        </Text>
      </View>
    );
  }

  if (!currentPageData) {
    return null;
  }

  const pageType = currentPageData.page_type || currentPageData.type || 'content';

  return (
    <View style={styles.container}>
      {canGoBack && (
        <TouchableOpacity style={styles.backButton} onPress={goBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
      )}
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
        {/* Cover Image */}
        {currentPageData.cover && (
          <Image
            source={{ uri: currentPageData.cover }}
            style={styles.cover}
            resizeMode="cover"
          />
        )}

        {/* Page Title */}
        <Text style={styles.title}>{currentPageData.title}</Text>

        {/* Page Content - Render HTML */}
        {pageType === 'content' && currentPageData.page_content && (
          <HTMLContentRenderer html={currentPageData.page_content} onNavigate={navigateToPage} />
        )}

        {/* Collection Item Type - Render HTML */}
        {pageType === 'collection-item' && currentPageData.data?.page_content && (
          <HTMLContentRenderer html={currentPageData.data.page_content} onNavigate={navigateToPage} />
        )}

        {/* Collection Type - Show children */}
        {pageType === 'collection' && (
          <View style={styles.contentSection}>
            {currentPageData.children && currentPageData.children.length > 0 ? (
              <View>
                <Text style={styles.sectionTitle}>Collection Items</Text>
                {currentPageData.children.map((child: any, index: number) => (
                  <TouchableOpacity
                    key={index}
                    style={styles.collectionItem}
                    onPress={() => navigateToPage(child.uuid)}
                  >
                    <Text style={styles.collectionItemTitle}>
                      {child.title || child.type || 'Untitled'}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            ) : (
              <Text style={styles.emptyText}>No items in this collection</Text>
            )}
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
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#f5f5f5',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  backButtonText: {
    fontSize: 16,
    color: '#1976d2',
    fontWeight: '600',
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
  cover: {
    width: '100%',
    aspectRatio: 16 / 9,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    paddingHorizontal: 16,
    paddingTop: 24,
    paddingBottom: 8,
    color: '#333',
  },
  contentSection: {
    paddingHorizontal: 16,
    paddingTop: 16,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 16,
    color: '#333',
  },
  collectionItem: {
    padding: 16,
    backgroundColor: '#f9f9f9',
    borderRadius: 8,
    marginBottom: 8,
  },
  collectionItemTitle: {
    fontSize: 18,
    fontWeight: '500',
    color: '#333',
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    paddingVertical: 24,
  },
});
