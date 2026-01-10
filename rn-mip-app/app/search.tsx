import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Keyboard,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Ionicons from '@expo/vector-icons/Ionicons';
import { searchSite, SearchResult } from '../lib/api';
import { getConfig } from '../lib/config';
import { getCachedSearch, setCachedSearch } from '../lib/searchCache';

export default function SearchScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const config = getConfig();
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [hasSearched, setHasSearched] = useState(false);
  
  // AbortController ref to cancel previous requests
  const abortControllerRef = useRef<AbortController | null>(null);

  // Debounce search - wait 500ms after user stops typing
  useEffect(() => {
    if (query.trim().length < 3) {
      setResults([]);
      setHasSearched(false);
      return;
    }

    const timeoutId = setTimeout(() => {
      performSearch(query.trim());
    }, 500);

    return () => clearTimeout(timeoutId);
  }, [query]);

  const performSearch = async (searchQuery: string) => {
    if (searchQuery.length < 3) {
      setResults([]);
      setHasSearched(false);
      return;
    }

    const searchStartTime = performance.now();
    const searchStartTimeMs = Date.now();
    console.log(`[Search] ===== Starting search for: "${searchQuery}" =====`);
    console.log(`[Search] Timestamp: ${searchStartTimeMs} (${new Date(searchStartTimeMs).toISOString()})`);

    // Cancel previous request if it exists
    if (abortControllerRef.current) {
      console.log('[Search] Cancelling previous search request');
      abortControllerRef.current.abort();
    }

    // Check cache first
    const cacheCheckStartTime = performance.now();
    const cachedResults = getCachedSearch(searchQuery);
    const cacheCheckEndTime = performance.now();
    const cacheCheckDuration = cacheCheckEndTime - cacheCheckStartTime;
    
    if (cachedResults !== null) {
      const cacheRenderStartTime = performance.now();
      setResults(cachedResults);
      setHasSearched(true);
      setIsLoading(false);
      const cacheRenderEndTime = performance.now();
      const totalCacheTime = cacheRenderEndTime - searchStartTime;
      const cacheRenderDuration = cacheRenderEndTime - cacheRenderStartTime;
      
      console.log(`[Search] Cache check: ${cacheCheckDuration.toFixed(2)}ms`);
      console.log(`[Search] Cache render: ${cacheRenderDuration.toFixed(2)}ms`);
      console.log(`[Search] Cache hit! Returning ${cachedResults.length} results`);
      console.log(`[Search] Total cache time: ${totalCacheTime.toFixed(2)}ms`);
      console.log(`[Search] ===== Search complete (cache) =====`);
      return;
    }

    console.log(`[Search] Cache miss (check took ${cacheCheckDuration.toFixed(2)}ms)`);

    // Create new AbortController for this request
    const abortController = new AbortController();
    abortControllerRef.current = abortController;

    const setLoadingStartTime = performance.now();
    setIsLoading(true);
    setHasSearched(true);
    const setLoadingEndTime = performance.now();
    console.log(`[Search] Set loading state: ${(setLoadingEndTime - setLoadingStartTime).toFixed(2)}ms`);
    
    try {
      const apiStartTime = performance.now();
      const apiStartTimeMs = Date.now();
      console.log(`[Search] Calling searchSite API at ${apiStartTimeMs}`);
      
      const searchResults = await searchSite(searchQuery, abortController.signal);
      
      const apiEndTime = performance.now();
      const apiEndTimeMs = Date.now();
      const apiDuration = apiEndTime - apiStartTime;
      
      console.log(`[Search] API call completed at ${apiEndTimeMs}`);
      console.log(`[Search] API duration: ${apiDuration.toFixed(2)}ms`);
      console.log(`[Search] Received ${searchResults.length} results`);
      
      // Store in cache
      const cacheStoreStartTime = performance.now();
      setCachedSearch(searchQuery, searchResults);
      const cacheStoreEndTime = performance.now();
      const cacheStoreDuration = cacheStoreEndTime - cacheStoreStartTime;
      console.log(`[Search] Cache store: ${cacheStoreDuration.toFixed(2)}ms`);
      
      // Set results and measure rendering
      const renderStartTime = performance.now();
      const renderStartTimeMs = Date.now();
      console.log(`[Search] Setting results at ${renderStartTimeMs}`);
      setResults(searchResults);
      
      // Use requestAnimationFrame to measure when results actually render
      requestAnimationFrame(() => {
        const renderEndTime = performance.now();
        const renderEndTimeMs = Date.now();
        const renderDuration = renderEndTime - renderStartTime;
        const totalDuration = renderEndTime - searchStartTime;
        
        console.log(`[Search] Results rendered at ${renderEndTimeMs}`);
        console.log(`[Search] Render duration: ${renderDuration.toFixed(2)}ms`);
        console.log(`[Search] ===== Total search time: ${totalDuration.toFixed(2)}ms =====`);
        console.log(`[Search] Breakdown:`);
        console.log(`[Search]   - Cache check: ${cacheCheckDuration.toFixed(2)}ms`);
        console.log(`[Search]   - Set loading: ${(setLoadingEndTime - setLoadingStartTime).toFixed(2)}ms`);
        console.log(`[Search]   - API call: ${apiDuration.toFixed(2)}ms`);
        console.log(`[Search]   - Cache store: ${cacheStoreDuration.toFixed(2)}ms`);
        console.log(`[Search]   - Render: ${renderDuration.toFixed(2)}ms`);
        console.log(`[Search]   - Total: ${totalDuration.toFixed(2)}ms`);
      });
    } catch (error: any) {
      // Ignore AbortError - it's expected when cancelling requests
      if (error.name === 'AbortError' || error.name === 'AbortedError') {
        const abortTime = performance.now();
        const abortDuration = abortTime - searchStartTime;
        console.log(`[Search] Search was cancelled after ${abortDuration.toFixed(2)}ms (user continued typing)`);
        return;
      }
      
      const errorTime = performance.now();
      const errorDuration = errorTime - searchStartTime;
      console.error(`[Search] Error searching after ${errorDuration.toFixed(2)}ms:`, error);
      setResults([]);
    } finally {
      // Only clear loading state if this request wasn't cancelled
      if (!abortController.signal.aborted) {
        const clearLoadingStartTime = performance.now();
        setIsLoading(false);
        const clearLoadingEndTime = performance.now();
        console.log(`[Search] Clear loading state: ${(clearLoadingEndTime - clearLoadingStartTime).toFixed(2)}ms`);
      }
    }
  };

  const handleResultPress = (result: SearchResult) => {
    Keyboard.dismiss();
    router.push(`/page/${result.uuid}`);
  };

  const renderResult = ({ item }: { item: SearchResult }) => (
    <TouchableOpacity
      style={styles.resultItem}
      onPress={() => handleResultPress(item)}
      activeOpacity={0.7}
    >
      <View style={styles.resultContent}>
        <Text style={styles.resultTitle}>{item.title}</Text>
        {item.description && (
          <Text style={styles.resultDescription} numberOfLines={2}>
            {item.description}
          </Text>
        )}
      </View>
      <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
    </TouchableOpacity>
  );

  const renderEmptyState = () => {
    if (isLoading) {
      return (
        <View style={styles.emptyState}>
          <ActivityIndicator size="large" color={config.primaryColor} />
          <Text style={styles.emptyStateText}>Searching...</Text>
        </View>
      );
    }

    if (hasSearched && results.length === 0) {
      return (
        <View style={styles.emptyState}>
          <Ionicons name="search-outline" size={64} color="#cbd5e1" />
          <Text style={styles.emptyStateText}>No results found</Text>
          <Text style={styles.emptyStateSubtext}>
            Try a different search term
          </Text>
        </View>
      );
    }

    return (
      <View style={styles.emptyState}>
        <Ionicons name="search-outline" size={64} color="#cbd5e1" />
        <Text style={styles.emptyStateText}>Start typing to search</Text>
        <Text style={styles.emptyStateSubtext}>
          Search for pages, articles, and content
        </Text>
      </View>
    );
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => router.back()}
        >
          <Ionicons name="arrow-back" size={24} color="#0f172a" />
        </TouchableOpacity>
        <View style={styles.searchInputContainer}>
          <Ionicons name="search" size={20} color="#64748b" style={styles.searchIcon} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search..."
            placeholderTextColor="#94a3b8"
            value={query}
            onChangeText={setQuery}
            autoFocus
            returnKeyType="search"
            onSubmitEditing={() => performSearch(query.trim())}
          />
          {query.length > 0 && (
            <TouchableOpacity
              style={styles.clearButton}
              onPress={() => {
                // Cancel any pending request
                if (abortControllerRef.current) {
                  abortControllerRef.current.abort();
                  abortControllerRef.current = null;
                }
                setQuery('');
                setResults([]);
                setHasSearched(false);
              }}
            >
              <Ionicons name="close-circle" size={20} color="#94a3b8" />
            </TouchableOpacity>
          )}
        </View>
      </View>

      {/* Results */}
      {results.length > 0 ? (
        <FlatList
          data={results}
          renderItem={renderResult}
          keyExtractor={(item) => item.uuid}
          contentContainerStyle={styles.resultsList}
          keyboardShouldPersistTaps="handled"
        />
      ) : (
        <View style={styles.emptyContainer}>{renderEmptyState()}</View>
      )}
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
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
    gap: 12,
  },
  backButton: {
    padding: 4,
  },
  searchInputContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f8fafc',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  searchIcon: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: '#0f172a',
    padding: 0,
  },
  clearButton: {
    marginLeft: 8,
    padding: 4,
  },
  resultsList: {
    paddingVertical: 8,
  },
  resultItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  resultContent: {
    flex: 1,
    marginRight: 12,
  },
  resultTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#0f172a',
    marginBottom: 4,
  },
  resultDescription: {
    fontSize: 14,
    color: '#64748b',
    lineHeight: 20,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyState: {
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  emptyStateText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#475569',
    marginTop: 16,
    textAlign: 'center',
  },
  emptyStateSubtext: {
    fontSize: 14,
    color: '#94a3b8',
    marginTop: 8,
    textAlign: 'center',
  },
});
