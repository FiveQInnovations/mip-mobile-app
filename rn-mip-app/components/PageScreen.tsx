import React from 'react';
import { View, Text, ScrollView, Image, StyleSheet, ActivityIndicator, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { getPage, PageData } from '../lib/api';
import { getConfig } from '../lib/config';
import { HTMLContentRenderer } from './HTMLContentRenderer';
import { ErrorScreen } from './ErrorScreen';
import { AudioPlayer } from './AudioPlayer';

interface PageScreenProps {
  uuid: string;
}

export function PageScreen({ uuid }: PageScreenProps) {
  const [pageData, setPageData] = React.useState<PageData | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<Error | null>(null);
  const config = getConfig();
  const router = useRouter();

  React.useEffect(() => {
    loadPage();
  }, [uuid]);

  async function loadPage() {
    try {
      setLoading(true);
      const data = await getPage(uuid);
      setPageData(data);
      setError(null);
    } catch (err: any) {
      setError(err instanceof Error ? err : new Error(err.message || 'Failed to load page'));
      console.error('Error loading page:', err);
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
    return <ErrorScreen error={error} onRetry={loadPage} retrying={loading} />;
  }

  if (!pageData) {
    return null;
  }

  const pageType = pageData.page_type || pageData.type || 'content';

  // Check if this is an audio item with audio content
  const isAudioItem = pageType === 'collection-item' && pageData.type === 'audio';
  const audioUrl = pageData.data?.content?.audio_url;
  const audioTitle = pageData.data?.content?.audio_name || pageData.title;
  const audioArtist = pageData.data?.content?.audio_credit;

  return (
    <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
      {/* Cover Image */}
      {pageData.cover && (
        <Image
          source={{ uri: pageData.cover }}
          style={styles.cover}
          resizeMode="cover"
        />
      )}

      {/* Page Title */}
      <Text style={styles.title}>{pageData.title}</Text>

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

      {/* Page Content - Render HTML */}
      {pageType === 'content' && pageData.page_content && (
        <HTMLContentRenderer html={pageData.page_content} />
      )}

      {/* Collection Type */}
      {pageType === 'collection' && (
        <View style={styles.contentSection}>
          {pageData.children && pageData.children.length > 0 ? (
            <View>
              <Text style={styles.sectionTitle}>Collection Items</Text>
              {pageData.children.map((child: any, index: number) => (
                <Pressable
                  key={child.uuid || index}
                  style={({pressed}) => [
                    styles.collectionItem,
                    pressed && { opacity: 0.5, backgroundColor: '#f0f0f0' }
                  ]}
                  onPress={() => {
                    if (child.uuid) {
                      router.push(`/page/${child.uuid}`);
                    }
                  }}
                  hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
                  testID={`collection-item-${index}`}
                  accessible={true}
                  accessibilityRole="button"
                  accessibilityLabel={child.title || child.type || 'Untitled'}
                  accessibilityHint="Tap to view details"
                >
                  <Text style={styles.collectionItemTitle}>
                    {child.title || child.type || 'Untitled'}
                  </Text>
                </Pressable>
              ))}
            </View>
          ) : (
            <Text style={styles.emptyText}>No items in this collection</Text>
          )}
        </View>
      )}

      {/* Collection Item Type - Render HTML */}
      {pageType === 'collection-item' && pageData.data?.page_content && (
        <HTMLContentRenderer html={pageData.data.page_content} />
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
    paddingBottom: 20,
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
  contentText: {
    fontSize: 16,
    lineHeight: 24,
    color: '#333',
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

