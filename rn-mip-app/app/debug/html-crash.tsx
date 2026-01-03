import React from 'react';
import { ScrollView, Text, View, StyleSheet } from 'react-native';
import { HTMLContentRenderer } from '../../components/HTMLContentRenderer';
import { resourcesCrashHtml } from '../../fixtures/resourcesCrashHtml';

export default function HtmlCrashScreen() {
  return (
    <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
      <Text
        style={styles.title}
        accessibilityLabel="HTML crash fixture heading"
        testID="html-crash-heading"
      >
        HTML Crash Fixture
      </Text>
      <Text style={styles.subtitle}>
        This screen renders a minimal HTML snippet from the Resources page to reproduce the current
        crash involving nested picture/source tags inside links.
      </Text>
      <View style={styles.rendererContainer}>
        <HTMLContentRenderer html={resourcesCrashHtml} />
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scrollView: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  content: {
    padding: 16,
    paddingBottom: 40,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 8,
    color: '#111827',
  },
  subtitle: {
    fontSize: 16,
    color: '#374151',
    marginBottom: 16,
  },
  rendererContainer: {
    borderWidth: 1,
    borderColor: '#e5e7eb',
    borderRadius: 8,
    paddingVertical: 8,
  },
});
