import React from 'react';
import { View, StyleSheet, Linking, useWindowDimensions, Image } from 'react-native';
import RenderHTML, { HTMLSource } from 'react-native-render-html';
import { useRouter } from 'expo-router';
import { getConfig } from '../lib/config';

interface HTMLContentRendererProps {
  html: string;
  baseUrl?: string;
  onNavigate?: (uuid: string) => void;
}

export function HTMLContentRenderer({ html, baseUrl, onNavigate }: HTMLContentRendererProps) {
  const router = useRouter();
  const config = getConfig();
  const apiBaseUrl = baseUrl || config.apiBaseUrl;
  const { width } = useWindowDimensions();

  // Remove problematic tags before parsing to avoid react-native-render-html crashing
  const sanitizeHtml = (input: string): string => {
    if (!input) return '';
    // Drop <source> tags entirely
    let working = input.replace(/<source[^>]*\/?>/gi, '');

    // Replace <picture>...<img>...</picture> with just the first <img> tag
    working = working.replace(/<picture[^>]*>([\s\S]*?)<\/picture>/gi, (_m, inner) => {
      const imgMatch = inner.match(/<img[^>]*>/i);
      return imgMatch ? imgMatch[0] : '';
    });

    // Remove any img with empty src which can produce invalid nodes
    working = working.replace(/<img[^>]*\ssrc\s*=\s*""[^>]*>/gi, '');

    return working;
  };

  // Extract UUID from /page/{uuid} URLs
  const extractUuidFromUrl = (href: string): string | null => {
    const match = href.match(/\/page\/([a-zA-Z0-9-]+)/);
    return match ? match[1] : null;
  };

  // Check if URL is internal (same domain or relative)
  const isInternalLink = (href: string): boolean => {
    try {
      const url = new URL(href, apiBaseUrl);
      const currentDomain = new URL(apiBaseUrl).hostname;
      return url.hostname === currentDomain || href.startsWith('/');
    } catch {
      // If URL parsing fails, treat relative URLs as internal
      return href.startsWith('/') || href.startsWith('./') || href.startsWith('../');
    }
  };

  // Resolve image source URL - handles relative URLs and validates
  const resolveImageSource = (src: string | undefined | null): string | null => {
    if (!src || src.trim() === '' || src === 'about:///blank' || src.startsWith('about://')) {
      return null;
    }

    // If it's already a full URL, return it
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return src;
    }

    // If it's a data URL, return it
    if (src.startsWith('data:')) {
      return src;
    }

    // Resolve relative URLs against baseUrl
    try {
      const resolvedUrl = new URL(src, apiBaseUrl);
      return resolvedUrl.toString();
    } catch {
      // If URL resolution fails, return null to skip rendering
      return null;
    }
  };

  // Calculate image width based on content width (accounting for padding)
  const imageWidth = width - 32; // Subtract horizontal padding

  // Custom renderer for image tags
  const renderers = {
    img: ({ tnode }: any) => {
      // Attributes are in tnode.attributes, not directly in props
      const src = tnode?.attributes?.src;
      const alt = tnode?.attributes?.alt;
      const resolvedSrc = resolveImageSource(src);

      // If source is invalid or empty, don't render the image
      if (!resolvedSrc) {
        return null;
      }

      return (
        <Image
          source={{ uri: resolvedSrc }}
          style={[styles.htmlImage, { width: imageWidth }]}
          resizeMode="contain"
          accessibilityLabel={alt}
        />
      );
    },
    // Note: <picture> elements are sanitized out and replaced with <img> before
    // passing to RenderHTML, so no picture renderer is needed. The img renderer
    // handles all image rendering.
    figure: ({ TDefaultRenderer, tnode, ...props }: any) => {
      // Render figure contents (will now properly handle picture inside)
      // Explicitly pass tnode to ensure it's not lost
      return <TDefaultRenderer tnode={tnode} {...props} />;
    }
  };

  const renderersProps = {
    a: {
      onPress: (event: any, href: string) => {
        // Prevent default behavior (opening in browser via Linking.openURL)
        event?.preventDefault?.();
        
        console.log('[HTMLContentRenderer] Link pressed:', href);

        if (!href) return;

        // Check if it's a /page/{uuid} link (already transformed by server)
        const uuid = extractUuidFromUrl(href);
        if (uuid) {
          console.log('[HTMLContentRenderer] UUID link detected:', uuid);
          if (onNavigate) {
            onNavigate(uuid);
          } else {
            router.push(`/page/${uuid}`);
          }
          return;
        }

        // Check if it's an internal link
        const isInternal = isInternalLink(href);
        console.log('[HTMLContentRenderer] Link type check - href:', href, 'isInternal:', isInternal);
        
        if (isInternal) {
          // Try to extract UUID from internal URLs
          const internalUuid = extractUuidFromUrl(href);
          if (internalUuid) {
            console.log('[HTMLContentRenderer] Internal UUID link detected:', internalUuid);
            if (onNavigate) {
              onNavigate(internalUuid);
            } else {
              router.push(`/page/${internalUuid}`);
            }
            return;
          }
          // For other internal links, log for now
          console.log('[HTMLContentRenderer] Internal link (non-UUID) detected:', href);
          return;
        }

        // External link - open in browser
        console.log('[HTMLContentRenderer] External link detected:', href);
        Linking.openURL(href)
          .then(() => {
            console.log('[HTMLContentRenderer] Linking.openURL succeeded for:', href);
          })
          .catch((err) => {
            console.error('[HTMLContentRenderer] Linking.openURL failed for:', href, 'Error:', err);
          });
      }
    }
  };

  const cleanHtml = sanitizeHtml(html);
  console.log('[HTMLContentRenderer] Original HTML length:', html.length);
  console.log('[HTMLContentRenderer] Cleaned HTML length:', cleanHtml.length);
  // Log first 100 chars of cleaned HTML to verify
  console.log('[HTMLContentRenderer] Cleaned HTML start:', cleanHtml.substring(0, 100));

  const source: HTMLSource = {
    html: cleanHtml,
  };

  // Base styles for HTML content - use config colors for brand consistency
  const baseStyle = {
    fontSize: 16,
    lineHeight: 26,
    color: '#475569',
  };

  // Use config colors for brand consistency
  const textColor = config.textColor || '#0f172a';
  const secondaryColor = config.secondaryColor || '#024D91';
  const primaryColor = config.primaryColor || '#D9232A';

  const tagsStyles = {
    body: {
      margin: 0,
      padding: 0,
    },
    p: {
      marginTop: 14,
      marginBottom: 14,
      ...baseStyle,
      color: '#475569',
    },
    h1: {
      fontSize: 28,
      fontWeight: 'bold' as const,
      marginTop: 28,
      marginBottom: 16,
      color: textColor,
      letterSpacing: -0.5,
    },
    h2: {
      fontSize: 24,
      fontWeight: 'bold' as const,
      marginTop: 24,
      marginBottom: 14,
      color: textColor,
      letterSpacing: -0.3,
    },
    h3: {
      fontSize: 20,
      fontWeight: '700' as const,
      marginTop: 20,
      marginBottom: 12,
      color: secondaryColor,
    },
    h4: {
      fontSize: 18,
      fontWeight: '600' as const,
      marginTop: 18,
      marginBottom: 10,
      color: secondaryColor,
    },
    h5: {
      fontSize: 16,
      fontWeight: '600' as const,
      marginTop: 16,
      marginBottom: 8,
      color: textColor,
    },
    h6: {
      fontSize: 14,
      fontWeight: '600' as const,
      marginTop: 14,
      marginBottom: 6,
      color: textColor,
      textTransform: 'uppercase' as const,
      letterSpacing: 0.5,
    },
    ul: {
      marginTop: 14,
      marginBottom: 14,
      paddingLeft: 20,
    },
    ol: {
      marginTop: 14,
      marginBottom: 14,
      paddingLeft: 20,
    },
    li: {
      marginBottom: 10,
      ...baseStyle,
      color: '#475569',
    },
    img: {
      marginTop: 20,
      marginBottom: 20,
    },
    a: {
      color: primaryColor,
      textDecorationLine: 'underline' as const,
      fontWeight: '500' as const,
    },
    blockquote: {
      borderLeftWidth: 4,
      borderLeftColor: primaryColor,
      paddingLeft: 16,
      paddingVertical: 8,
      marginTop: 16,
      marginBottom: 16,
      backgroundColor: '#f8fafc',
      fontStyle: 'italic' as const,
      ...baseStyle,
      color: '#64748b',
    },
    hr: {
      marginTop: 24,
      marginBottom: 24,
      borderTopWidth: 2,
      borderTopColor: '#e2e8f0',
    },
    strong: {
      fontWeight: '700' as const,
      color: textColor,
    },
    em: {
      fontStyle: 'italic' as const,
    },
  };

  const systemFonts = ['System'];

  return (
    <View style={styles.container}>
      <RenderHTML
        contentWidth={width - 32}
        source={source}
        tagsStyles={tagsStyles}
        renderers={renderers}
        renderersProps={renderersProps}
        ignoredDomTags={['source', 'picture']}
        systemFonts={systemFonts}
        defaultTextProps={{
          style: baseStyle,
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  htmlImage: {
    aspectRatio: 16 / 9,
    marginTop: 20,
    marginBottom: 20,
    borderRadius: 8,
  },
});
