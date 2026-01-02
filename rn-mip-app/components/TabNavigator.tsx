import React from 'react';
import { View, Text, StyleSheet, ActivityIndicator, TouchableOpacity } from 'react-native';
import { getSiteData, SiteData, MenuItem } from '../lib/api';
import { getConfig } from '../lib/config';
import { TabScreen } from './TabScreen';
import { HomeScreen } from './HomeScreen';

export function TabNavigator() {
  const [siteData, setSiteData] = React.useState<SiteData | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);
  const [selectedTabUuid, setSelectedTabUuid] = React.useState<string | null>(null);
  const config = getConfig();

  React.useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    try {
      setLoading(true);
      const data = await getSiteData();
      setSiteData(data);
      setError(null);
      // Set Home tab as selected by default
      setSelectedTabUuid('__home__');
    } catch (err: any) {
      setError(err.message || 'Failed to load data');
      console.error('Error loading site data:', err);
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
    return (
      <View style={styles.container}>
        <Text style={styles.errorText}>API Error: {error}</Text>
        <Text style={styles.retryText} onPress={loadData}>
          Tap to retry
        </Text>
      </View>
    );
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
    icon: '🏠',
    page: { uuid: '__home__', type: 'home', url: '/' }
  };

  // Prepend Home tab to menu items
  const menuItems = siteData.menu;
  const allTabs = [homeTab, ...menuItems];
  const selectedTab = allTabs.find(item => item.page.uuid === selectedTabUuid) || allTabs[0];

  return (
    <View style={styles.container}>
      {/* Content Area */}
      <View style={styles.contentArea}>
        {selectedTabUuid === '__home__' ? (
          <HomeScreen 
            siteData={siteData}
            onSwitchTab={(uuid) => setSelectedTabUuid(uuid)}
          />
        ) : (
          selectedTabUuid && <TabScreen uuid={selectedTabUuid} />
        )}
      </View>

      {/* Bottom Tab Bar */}
      <View style={styles.tabBar}>
        {allTabs.map((item: MenuItem, index: number) => {
          const isSelected = selectedTabUuid === item.page.uuid;
          return (
            <TouchableOpacity
              key={index}
              style={[styles.tabItem, isSelected && styles.tabItemSelected]}
              onPress={() => setSelectedTabUuid(item.page.uuid)}
              accessibilityLabel={`${item.label} tab`}
              accessibilityRole="tab"
              accessibilityState={{ selected: isSelected }}
            >
              {item.icon && (
                <Text style={styles.tabIcon}>{item.icon}</Text>
              )}
              <Text
                style={[
                  styles.tabLabel,
                  isSelected && styles.tabLabelSelected,
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
    backgroundColor: '#ffffff',
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
    fontSize: 20,
    marginBottom: 4,
  },
  tabLabel: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
  tabLabelSelected: {
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
});
