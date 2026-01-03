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
    picture: ({ TDefaultRenderer, tnode, ...props }: any) => {
      // Find the <img> child inside <picture> (may be nested in <source> siblings)
      const findImgNode = (node: any): any => {
        if (!node) return null;
        if (node.tagName === 'img') return node;
        if (node.children) {
          for (const child of node.children) {
            const found = findImgNode(child);
            if (found) return found;
          }
        }
        return null;
      };
      
      const imgNode = findImgNode(tnode);
      if (imgNode) {
        const src = imgNode.attributes?.src;
        const alt = imgNode.attributes?.alt;
        const resolvedSrc = resolveImageSource(src);
        if (resolvedSrc) {
          return (
            <Image
              source={{ uri: resolvedSrc }}
              style={[styles.htmlImage, { width: imageWidth }]}
              resizeMode="contain"
              accessibilityLabel={alt}
            />
          );
        }
      }
      return null;
    },
    figure: ({ TDefaultRenderer, tnode, ...props }: any) => {
      // Render figure contents (will now properly handle picture inside)
      // Explicitly pass tnode to ensure it's not lost
      return <TDefaultRenderer tnode={tnode} {...props} />;
    }
  };

  const renderersProps = {
    a: {
      onPress: (event: any, href: string) => {
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

  // Base styles for HTML content
  const baseStyle = {
    fontSize: 16,
    lineHeight: 24,
    color: '#333',
  };

  const tagsStyles = {
    body: {
      margin: 0,
      padding: 0,
    },
    p: {
      marginTop: 12,
      marginBottom: 12,
      ...baseStyle,
    },
    h1: {
      fontSize: 28,
      fontWeight: 'bold' as const,
      marginTop: 24,
      marginBottom: 16,
      color: '#333',
    },
    h2: {
      fontSize: 24,
      fontWeight: 'bold' as const,
      marginTop: 20,
      marginBottom: 12,
      color: '#333',
    },
    h3: {
      fontSize: 20,
      fontWeight: '600' as const,
      marginTop: 16,
      marginBottom: 10,
      color: '#333',
    },
    h4: {
      fontSize: 18,
      fontWeight: '600' as const,
      marginTop: 14,
      marginBottom: 8,
      color: '#333',
    },
    ul: {
      marginTop: 12,
      marginBottom: 12,
      paddingLeft: 20,
    },
    ol: {
      marginTop: 12,
      marginBottom: 12,
      paddingLeft: 20,
    },
    li: {
      marginBottom: 8,
      ...baseStyle,
    },
    img: {
      marginTop: 16,
      marginBottom: 16,
    },
    a: {
      color: config.primaryColor,
      textDecorationLine: 'underline' as const,
    },
    blockquote: {
      borderLeftWidth: 4,
      borderLeftColor: '#ddd',
      paddingLeft: 16,
      marginTop: 12,
      marginBottom: 12,
      fontStyle: 'italic' as const,
      ...baseStyle,
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
        ignoredDomTags={['source']}
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
    paddingVertical: 8,
  },
  htmlImage: {
    aspectRatio: 16 / 9,
    marginTop: 16,
    marginBottom: 16,
  },
});
