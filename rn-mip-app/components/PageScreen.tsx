/**
 * PageScreen - Renders page content for Expo Router navigation.
 * 
 * Used by: app/page/[uuid].tsx for direct URL navigation
 * Navigation: Expo Router via router.push() - used by home cards, HTML links
 * 
 * Keep feature parity with TabScreen.tsx for collection/audio rendering.
 * Shared components: CollectionItemList, AudioPlayer
 */
import React from 'react';
import { View, Text, ScrollView, Image, StyleSheet, ActivityIndicator, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { getPage, PageData } from '../lib/api';
import { getConfig } from '../lib/config';
import { HTMLContentRenderer } from './HTMLContentRenderer';
import { ErrorScreen } from './ErrorScreen';
import { AudioPlayer } from './AudioPlayer';
import { CollectionItemList } from './CollectionItemList';

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
  // Read from structured audio data, fallback to content for backward compatibility
  const audioUrl = pageData.data?.audio?.audio_url || pageData.data?.content?.audio_url;
  const audioTitle = pageData.data?.audio?.audio_name || pageData.data?.content?.audio_name || pageData.title;
  const audioArtist = pageData.data?.audio?.audio_credit || pageData.data?.content?.audio_credit;

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
          {/* DEBUG: Show audio URL for verification - remove after testing */}
          <Text style={{ fontSize: 10, color: '#999', padding: 8 }}>
            URL: {audioUrl ? audioUrl.substring(0, 50) + '...' : 'NONE'}
          </Text>
        </View>
      )}

      {/* Page Content - Render HTML */}
      {pageType === 'content' && pageData.page_content && (
        <HTMLContentRenderer html={pageData.page_content} />
      )}

      {/* Collection Type */}
      {pageType === 'collection' && (
        <View style={styles.contentSection}>
          <CollectionItemList 
            children={pageData.children || []}
            onNavigate={(uuid) => router.push(`/page/${uuid}`)}
            primaryColor={config.primaryColor}
            textColor={config.textColor || '#0f172a'}
          />
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
});

