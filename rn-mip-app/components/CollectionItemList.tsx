import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';

interface CollectionChild {
  uuid?: string;
  title?: string;
  type?: string;
  description?: string;
}

interface CollectionItemListProps {
  children: CollectionChild[];
  onNavigate: (uuid: string) => void;
  primaryColor?: string;
  textColor?: string;
}

/**
 * CollectionItemList - Renders a list of collection items with navigation.
 * 
 * Shared by: TabScreen.tsx and PageScreen.tsx
 * Handles: Press feedback, accessibility, navigation callback
 */
export function CollectionItemList({ 
  children, 
  onNavigate,
  primaryColor = '#0066cc',
  textColor = '#0f172a'
}: CollectionItemListProps) {
  if (!children || children.length === 0) {
    return (
      <Text style={styles.emptyText}>No items in this collection</Text>
    );
  }

  return (
    <View>
      <Text style={[styles.sectionTitle, { color: textColor }]}>
        {children.length} Items
      </Text>
      {children.map((child, index) => {
        const handlePress = () => {
          if (child.uuid) {
            onNavigate(child.uuid);
          }
        };
        
        return (
          <Pressable
            key={child.uuid || index}
            style={({pressed}) => [
              styles.collectionItem,
              { borderLeftColor: primaryColor },
              pressed && { opacity: 0.5, backgroundColor: '#f0f0f0' }
            ]}
            onPress={handlePress}
            hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
            testID={`collection-item-${index}`}
            accessible={true}
            accessibilityRole="button"
            accessibilityLabel={child.title || child.type || 'Untitled'}
            accessibilityHint="Tap to view details"
          >
            <View style={styles.collectionItemContent}>
              <Text style={styles.collectionItemTitle}>
                {child.title || child.type || 'Untitled'}
              </Text>
              {child.description && (
                <Text style={styles.collectionItemDescription} numberOfLines={3}>
                  {child.description}
                </Text>
              )}
            </View>
            <Text style={styles.collectionChevron}>›</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  sectionTitle: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 12,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  collectionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
    backgroundColor: '#ffffff',
    borderRadius: 12,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#e5e7eb',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 3 },
    elevation: 3,
  },
  collectionItemContent: {
    flex: 1,
    paddingRight: 8,
  },
  collectionItemTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#0f172a',
    marginBottom: 2,
  },
  collectionItemDescription: {
    fontSize: 14,
    color: '#64748b',
    lineHeight: 20,
  },
  collectionChevron: {
    fontSize: 22,
    color: '#94a3b8',
    fontWeight: '300',
  },
  emptyText: {
    fontSize: 16,
    color: '#64748b',
    textAlign: 'center',
    paddingVertical: 32,
    fontStyle: 'italic',
  },
});
