import React from 'react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { View, StyleSheet, TouchableOpacity, Text, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Ionicons from '@expo/vector-icons/Ionicons';
import { PageScreen } from '../../components/PageScreen';
import { getSiteData, MenuItem } from '../../lib/api';
import { getConfig } from '../../lib/config';

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

const DEFAULT_ICON = { filled: 'ellipse' as keyof typeof Ionicons.glyphMap, outline: 'ellipse-outline' as keyof typeof Ionicons.glyphMap };

// Allowed tab labels for bottom navigation (4 tabs total: Home + 3 menu items)
const ALLOWED_TAB_LABELS = ['Resources', 'Chapters', 'Connect'];

export default function Page() {
  const { uuid } = useLocalSearchParams<{ uuid: string }>();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const config = getConfig();
  const [siteData, setSiteData] = React.useState<any>(null);
  
  React.useEffect(() => {
    // Fetch site data to render tabs
    getSiteData().then(data => setSiteData(data)).catch(console.error);
  }, []);
  
  if (!uuid) {
    return null;
  }

  const handleTabPress = (tabUuid: string) => {
    if (tabUuid === '__home__') {
      router.replace('/');
    } else {
      router.replace(`/page/${tabUuid}`);
    }
  };

  const homeTab: MenuItem = {
    label: 'Home',
    page: { uuid: '__home__', type: 'home', url: '/' }
  };

  // Filter menu items to only include Resources, Chapters, and Connect
  // This ensures we have exactly 4 tabs total (Home + 3 menu items)
  const filteredMenuItems = siteData 
    ? siteData.menu.filter(item => ALLOWED_TAB_LABELS.includes(item.label.trim()))
    : [];
  const allTabs = siteData ? [homeTab, ...filteredMenuItems] : [];

  return (
    <View style={styles.container}>
      {/* Custom header with back button */}
      <View style={[styles.header, { paddingTop: insets.top }]}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => router.back()}
          accessibilityLabel="Go back"
          accessibilityRole="button"
        >
          <Ionicons name="arrow-back" size={24} color="#0f172a" />
          <Text style={styles.backButtonText}>Back</Text>
        </TouchableOpacity>
      </View>
      
      {/* Page content */}
      <View style={styles.content}>
        <PageScreen uuid={uuid} />
      </View>

      {/* Bottom Tab Bar */}
      {siteData && (
        <View style={[styles.tabBar, { paddingBottom: Platform.OS === 'android' ? insets.bottom : 0 }]}>
          {allTabs.map((item: MenuItem, index: number) => {
            const isSelected = uuid === item.page.uuid;
            const cleanLabel = item.label.trim();
            
            return (
              <TouchableOpacity
                key={index}
                style={[styles.tabItem, isSelected && styles.tabItemSelected]}
                onPress={() => handleTabPress(item.page.uuid)}
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
    backgroundColor: '#ffffff',
    zIndex: 10,
  },
  backButton: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 4,
  },
  backButtonText: {
    marginLeft: 4,
    fontSize: 16,
    color: '#0f172a',
    fontWeight: '500',
  },
  content: {
    flex: 1,
    paddingBottom: 60, // Space for tabs
  },
  tabBar: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
    backgroundColor: '#ffffff',
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
});