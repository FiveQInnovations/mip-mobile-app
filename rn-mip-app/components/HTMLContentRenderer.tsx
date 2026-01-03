import React from 'react';
import { View, StyleSheet, Linking, TouchableOpacity, useWindowDimensions, Image } from 'react-native';
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
    img: ({ TDefaultRenderer, ...props }: any) => {
      const { src, ...restProps } = props;
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
        />
      );
    },
    picture: ({ TDefaultRenderer, tnode, ...props }: any) => {
      // Find the <img> child inside <picture> (may be nested in <source> siblings)
      const findImgNode = (node: any): any => {
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
    figure: ({ TDefaultRenderer, ...props }: any) => {
      // Render figure contents (will now properly handle picture inside)
      return <TDefaultRenderer {...props} />;
    },
    a: ({ TDefaultRenderer, ...props }: any) => {
      const { href, ...restProps } = props;
      
      if (!href) {
        return <TDefaultRenderer {...props} />;
      }

      // Check if it's a /page/{uuid} link (already transformed by server)
      const uuid = extractUuidFromUrl(href);
      if (uuid) {
        return (
          <TouchableOpacity
            onPress={() => {
              if (onNavigate) {
                onNavigate(uuid);
              } else {
                router.push(`/page/${uuid}`);
              }
            }}
            activeOpacity={0.7}
          >
            <TDefaultRenderer {...restProps} />
          </TouchableOpacity>
        );
      }

      // Check if it's an internal link
      if (isInternalLink(href)) {
        // Try to extract UUID from internal URLs
        const internalUuid = extractUuidFromUrl(href);
        if (internalUuid) {
          return (
            <TouchableOpacity
              onPress={() => {
                if (onNavigate) {
                  onNavigate(internalUuid);
                } else {
                  router.push(`/page/${internalUuid}`);
                }
              }}
              activeOpacity={0.7}
            >
              <TDefaultRenderer {...restProps} />
            </TouchableOpacity>
          );
        }
        // For other internal links, we could navigate or handle differently
        // For now, just render as normal link
        return (
          <TouchableOpacity
            onPress={() => {
              // Could implement URL-to-UUID mapping here if needed
              console.log('Internal link clicked:', href);
            }}
            activeOpacity={0.7}
          >
            <TDefaultRenderer {...restProps} />
          </TouchableOpacity>
        );
      }

      // External link - open in browser
      return (
        <TouchableOpacity
          onPress={() => Linking.openURL(href)}
          activeOpacity={0.7}
        >
          <TDefaultRenderer {...restProps} />
        </TouchableOpacity>
      );
    },
  };

  const source: HTMLSource = {
    html,
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

