import React from 'react';
import { View, Text, StyleSheet, ActivityIndicator, TouchableOpacity, InteractionManager, Platform, BackHandler } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Ionicons from '@expo/vector-icons/Ionicons';
import { getSiteData, SiteData, MenuItem, prefetchMainTabs } from '../lib/api';
import { getConfig } from '../lib/config';
import { TabScreen } from './TabScreen';
import { HomeScreen } from './HomeScreen';
import { SplashScreen } from './SplashScreen';
import { ErrorScreen } from './ErrorScreen';

// Updated Icon Map based on the screenshot
// Home -> Star
// Resources -> Bible (Book)
// Connect -> Arrow/Connect icon
// Give -> Heart
// Others -> Appropriate fallbacks
const TAB_ICONS: Record<string, { filled: keyof typeof Ionicons.glyphMap; outline: keyof typeof Ionicons.glyphMap }> = {
  'Home': { filled: 'star', outline: 'star-outline' },
  'Resources': { filled: 'book', outline: 'book-outline' },
  'Chapters': { filled: 'people', outline: 'people-outline' },
  'About': { filled: 'information-circle', outline: 'information-circle-outline' },
  'Get Involved': { filled: 'hand-left', outline: 'hand-left-outline' },
  'Prayer Request': { filled: 'heart', outline: 'heart-outline' },
  'Chaplain Request': { filled: 'person', outline: 'person-outline' },
  'Connect': { filled: 'git-network', outline: 'git-network-outline' },
  'Give': { filled: 'heart', outline: 'heart-outline' },
};

// Fallback icon for tabs not in the mapping
const DEFAULT_ICON = { filled: 'ellipse' as keyof typeof Ionicons.glyphMap, outline: 'ellipse-outline' as keyof typeof Ionicons.glyphMap };

// Allowed tab labels for bottom navigation (4 tabs total: Home + 3 menu items)
const ALLOWED_TAB_LABELS = ['Resources', 'Chapters', 'Connect'];

export function TabNavigator() {
  const [siteData, setSiteData] = React.useState<SiteData | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<Error | null>(null);
  const [selectedTabUuid, setSelectedTabUuid] = React.useState<string | null>(null);
  const config = getConfig();
  const insets = useSafeAreaInsets();
  
  // Tab navigation history for Android back button
  // Using ref to avoid re-renders on history changes
  const tabHistory = React.useRef<string[]>([]);

  // Navigate to a tab and track history
  const navigateToTab = React.useCallback((targetUuid: string) => {
    // Don't do anything if navigating to the same tab
    if (targetUuid === selectedTabUuid) return;
    
    // Push current tab to history before navigating (if we have a current tab)
    if (selectedTabUuid) {
      tabHistory.current.push(selectedTabUuid);
      console.log(`[TabNavigator] History updated: [${tabHistory.current.join(', ')}]`);
    }
    
    setSelectedTabUuid(targetUuid);
  }, [selectedTabUuid]);

  React.useEffect(() => {
    loadData();
  }, []);

  // Handle Android back button with history support
  React.useEffect(() => {
    if (Platform.OS !== 'android') return;

    const backHandler = BackHandler.addEventListener('hardwareBackPress', () => {
      // If there's history, go back to the previous tab
      if (tabHistory.current.length > 0) {
        const previousTab = tabHistory.current.pop();
        console.log(`[TabNavigator] Back pressed, navigating to: ${previousTab}`);
        setSelectedTabUuid(previousTab!); // Use setSelectedTabUuid directly to avoid pushing to history
        return true; // Prevent default (exit app)
      }
      
      // If on Home with no history, allow app exit
      if (selectedTabUuid === '__home__') {
        console.log('[TabNavigator] On Home with no history, allowing exit');
        return false;
      }
      
      // If somehow not on Home with no history, go to Home
      console.log('[TabNavigator] No history, navigating to Home');
      setSelectedTabUuid('__home__');
      return true;
    });

    return () => backHandler.remove();
  }, [selectedTabUuid]);

  async function loadData() {
    try {
      setLoading(true);
      const data = await getSiteData();
      setSiteData(data);
      setError(null);
      // Set Home tab as selected by default
      setSelectedTabUuid('__home__');
      
      // Filter menu items to only include allowed tabs
      const filteredMenu = data.menu.filter(item => 
        ALLOWED_TAB_LABELS.includes(item.label.trim())
      );
      
      // Prefetch all main tab content after critical path (homepage) loads
      // Use InteractionManager to run after animations/interactions complete
      InteractionManager.runAfterInteractions(() => {
        console.log('[TabNavigator] Site data loaded, starting prefetch of main tabs...');
        prefetchMainTabs(filteredMenu);
      });
    } catch (err: any) {
      setError(err instanceof Error ? err : new Error(err.message || 'Failed to load data'));
      console.error('Error loading site data:', err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return <SplashScreen />;
  }

  if (error) {
    return <ErrorScreen error={error} onRetry={loadData} retrying={loading} />;
  }

  if (!siteData || siteData.menu.length === 0) {
    return (
      <View style={styles.container}>
        <Text style={styles.errorText}>No menu items available</Text>
      </View>
    );
  }

  // Create Home tab item
  const homeTab: MenuItem = {
    label: 'Home',
    page: { uuid: '__home__', type: 'home', url: '/' }
  };

  // Filter menu items to only include Resources, Chapters, and Connect
  // This ensures we have exactly 4 tabs total (Home + 3 menu items)
  const filteredMenuItems = siteData.menu.filter(item => 
    ALLOWED_TAB_LABELS.includes(item.label.trim())
  );
  const allTabs = [homeTab, ...filteredMenuItems];
  const selectedTab = allTabs.find(item => item.page.uuid === selectedTabUuid) || allTabs[0];

  return (
    <View style={styles.container}>
      {/* Content Area - paddingTop ensures content respects status bar safe area */}
      <View style={[styles.contentArea, { paddingTop: insets.top }]}>
        {selectedTabUuid === '__home__' ? (
          <HomeScreen 
            siteData={siteData}
            onSwitchTab={(uuid) => navigateToTab(uuid)}
          />
        ) : (
          selectedTabUuid && <TabScreen key={selectedTabUuid} uuid={selectedTabUuid} />
        )}
      </View>

      {/* Bottom Tab Bar */}
      <View style={[styles.tabBar, { paddingBottom: Platform.OS === 'android' ? insets.bottom : 0 }]}>
        {allTabs.map((item: MenuItem, index: number) => {
          const isSelected = selectedTabUuid === item.page.uuid;
          // Clean label for icon lookup (handle potential trailing spaces or case)
          const cleanLabel = item.label.trim();
          
          return (
            <TouchableOpacity
              key={index}
              style={[styles.tabItem, isSelected && styles.tabItemSelected]}
              onPress={() => {
                const tapTime = Date.now();
                console.log(`[TabNavigator] Tab tapped: ${item.label} (UUID: ${item.page.uuid}) at ${tapTime}`);
                navigateToTab(item.page.uuid);
              }}
              accessibilityLabel={`${item.label} tab`}
              accessibilityRole="tab"
              accessibilityState={{ selected: isSelected }}
            >
              <Ionicons
                name={(TAB_ICONS[cleanLabel] || DEFAULT_ICON)[isSelected ? 'filled' : 'outline']}
                size={22}
                color={isSelected ? config.primaryColor : '#666'}
                style={styles.tabIcon}
              />
              <Text
                style={[
                  styles.tabLabel,
                  isSelected && { color: config.primaryColor, fontWeight: '600' },
                ]}
              >
                {item.label}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  contentArea: {
    flex: 1,
  },
  tabBar: {
    flexDirection: 'row',
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
    backgroundColor: '#f8fafc',
    paddingBottom: 0,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: -2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 5,
    minHeight: 60,
  },
  tabItem: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 8,
    paddingHorizontal: 4,
    minHeight: 60,
  },
  tabItemSelected: {
    backgroundColor: '#f5f5f5',
  },
  tabIcon: {
    marginBottom: 2,
  },
  tabLabel: {
    fontSize: 11,
    color: '#666',
    textAlign: 'center',
    fontWeight: '500',
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
});
