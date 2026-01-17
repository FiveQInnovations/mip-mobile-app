import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, ViewStyle } from 'react-native';

interface ContentCardProps {
  title: string;
  description?: string;
  imageUrl?: string;
  onPress: () => void;
  style?: ViewStyle;
  testID?: string;
  badgeText?: string;
}

export function ContentCard({ 
  title, 
  description, 
  imageUrl, 
  onPress, 
  style, 
  testID,
  badgeText 
}: ContentCardProps) {
  return (
    <TouchableOpacity 
      style={[styles.card, style]} 
      onPress={onPress}
      testID={testID}
      accessibilityLabel={title}
      accessibilityRole="button"
    >
      <View style={styles.imageContainer}>
        {imageUrl ? (
          <Image 
            source={{ uri: imageUrl }} 
            style={styles.image} 
            resizeMode="cover"
          />
        ) : (
          <View style={[styles.image, styles.placeholderImage]} />
        )}
        
        {badgeText && (
          <View style={styles.badge}>
            <Text style={styles.badgeText}>{badgeText}</Text>
          </View>
        )}
      </View>
      
      <View style={styles.content}>
        <Text style={styles.title} numberOfLines={2}>{title}</Text>
        {description && (
          <Text style={styles.description} numberOfLines={2}>{description}</Text>
        )}
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: 16,
    // Shadow for iOS
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 4,
    // Elevation for Android
    elevation: 3,
    width: 280, // Default width for carousel items
  },
  imageContainer: {
    height: 158, // 16:9 aspect ratio relative to width 280 is approx 158
    backgroundColor: '#e5e7eb',
    position: 'relative',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  placeholderImage: {
    backgroundColor: '#cbd5e1',
  },
  badge: {
    position: 'absolute',
    top: 12,
    left: 12,
    backgroundColor: '#2563eb',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 4,
  },
  badgeText: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
  content: {
    padding: 16,
  },
  title: {
    fontSize: 18,
    fontWeight: '700',
    color: '#0f172a',
    marginBottom: 4,
    lineHeight: 24,
  },
  description: {
    fontSize: 14,
    color: '#64748b',
    lineHeight: 20,
  },
});
