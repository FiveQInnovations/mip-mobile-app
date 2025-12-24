import React from 'react';
import { View, Text, ScrollView, Image, StyleSheet, ActivityIndicator, TouchableOpacity } from 'react-native';
import { getPage, PageData } from '../lib/api';
import { getConfig } from '../lib/config';
import { HTMLContentRenderer } from './HTMLContentRenderer';

interface TabScreenProps {
  uuid: string;
}

export function TabScreen({ uuid }: TabScreenProps) {
  const [pageStack, setPageStack] = React.useState<string[]>([uuid]);
  const [currentPageData, setCurrentPageData] = React.useState<PageData | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);
  const config = getConfig();

  const currentUuid = pageStack[pageStack.length - 1];
  const canGoBack = pageStack.length > 1;

  React.useEffect(() => {
    if (currentUuid) {
      loadPage();
    }
  }, [currentUuid]);

  async function loadPage() {
    try {
      setLoading(true);
      const data = await getPage(currentUuid);
      setCurrentPageData(data);
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to load page');
      console.error('Error loading page:', err);
    } finally {
      setLoading(false);
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
