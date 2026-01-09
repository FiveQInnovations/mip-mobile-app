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

    const searchStartTime = Date.now();
    console.log(`[Search] Starting search for: "${searchQuery}" at ${searchStartTime}`);

    // Cancel previous request if it exists
    if (abortControllerRef.current) {
      console.log('[Search] Cancelling previous search request');
      abortControllerRef.current.abort();
    }

    // Check cache first
    const cachedResults = getCachedSearch(searchQuery);
    if (cachedResults !== null) {
      const cacheTime = Date.now() - searchStartTime;
      console.log(`[Search] Cache hit! Returning ${cachedResults.length} results in ${cacheTime}ms`);
      setResults(cachedResults);
      setHasSearched(true);
      setIsLoading(false);
      return;
    }

    // Create new AbortController for this request
    const abortController = new AbortController();
    abortControllerRef.current = abortController;

    setIsLoading(true);
    setHasSearched(true);
    
    try {
      const apiStartTime = Date.now();
      const searchResults = await searchSite(searchQuery, abortController.signal);
      const apiEndTime = Date.now();
      const apiDuration = apiEndTime - apiStartTime;
      const totalDuration = apiEndTime - searchStartTime;
      
      console.log(`[Search] API call completed in ${apiDuration}ms, total search time: ${totalDuration}ms`);
      console.log(`[Search] Received ${searchResults.length} results`);
      
      // Store in cache
      setCachedSearch(searchQuery, searchResults);
      
      setResults(searchResults);
    } catch (error: any) {
      // Ignore AbortError - it's expected when cancelling requests
      if (error.name === 'AbortError' || error.name === 'AbortedError') {
        console.log('[Search] Search was cancelled (user continued typing)');
        return;
      }
      
      console.error('[Search] Error searching:', error);
      setResults([]);
    } finally {
      // Only clear loading state if this request wasn't cancelled
      if (!abortController.signal.aborted) {
        setIsLoading(false);
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
