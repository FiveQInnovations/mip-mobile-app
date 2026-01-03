/**
 * Test the HTML sanitization logic used by HTMLContentRenderer.
 * This is a pure function test that runs in ~1 second.
 */

// Minimal fixture that mirrors the Resources page structure
const resourcesCrashHtml = `
<div class="_background" style=" --overlayDisplay: none;">
  <picture style="opacity: 0.7;">
    <source srcset="https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=2000" media="(min-width: 1024px)" type="image/webp">
    <source srcset="https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=1400" media="(min-width: 768px)" type="image/webp">
    <img
      fetchpriority="high"
      preload="eager"
      src="https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48"
      width="2000"
      height="1125"
      alt="black and white image of firemen with hoses"
    >
  </picture>
</div>

<a class="_image-link" href="https://harvest.org/know-god/how-to-know-god/">
  <figure class="_image w-full flex flex-col items-center">
    <div class="w-full">
      <picture>
        <source srcset="https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?width=1600" media="(min-width: 1280px)" type="image/webp">
        <img
          loading="lazy"
          src="https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0"
          width="800"
          height="448"
          alt="silhouette of a man kneeling in front of a cross"
        >
      </picture>
    </div>
  </figure>
</a>

<a class="_image-link" href="https://www.biblegateway.com/">
  <figure class="_image w-full flex flex-col items-center">
    <div class="w-full">
      <picture>
        <source srcset="https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?width=1600" media="(min-width: 1280px)" type="image/webp">
        <img
          loading="lazy"
          src="https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0"
          width="800"
          height="532"
          alt="Man reading a Bible"
        >
      </picture>
    </div>
  </figure>
</a>
`;

// Copy of the current sanitization logic from HTMLContentRenderer
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

describe('HTML Sanitization', () => {
  describe('sanitizeHtml', () => {
    it('should remove <source> tags', () => {
      const html = '<source srcset="test.jpg" media="(min-width: 1024px)" type="image/webp">';
      const result = sanitizeHtml(html);
      expect(result).toBe('');
    });

    it('should extract <img> from <picture> element', () => {
      const html = `<picture>
        <source srcset="test.webp" type="image/webp">
        <img src="test.jpg" alt="Test image">
      </picture>`;
      
      const result = sanitizeHtml(html);
      expect(result).toContain('<img');
      expect(result).toContain('src="test.jpg"');
      expect(result).toContain('alt="Test image"');
      expect(result).not.toContain('<picture');
      expect(result).not.toContain('<source');
    });

    it('should handle multi-line img tags inside picture', () => {
      const html = `<picture>
        <source srcset="test.webp" type="image/webp">
        <img
          loading="lazy"
          src="https://example.com/image.jpg"
          width="800"
          height="600"
          alt="Multi-line image"
        >
      </picture>`;
      
      const result = sanitizeHtml(html);
      expect(result).toContain('src="https://example.com/image.jpg"');
      expect(result).toContain('alt="Multi-line image"');
    });

    it('should preserve images from resourcesCrashHtml fixture', () => {
      const result = sanitizeHtml(resourcesCrashHtml);
      
      // Should contain the image URLs from the fixture
      expect(result).toContain('ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg');
      expect(result).toContain('ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg');
      expect(result).toContain('ffci-5q.b-cdn.net/image/rp2bbncw.jpg');
      
      // Should have img tags
      expect(result).toContain('<img');
      
      // Should not have source or picture tags
      expect(result).not.toContain('<source');
      expect(result).not.toContain('<picture');
      expect(result).not.toContain('</picture>');
    });

    it('should count correct number of img tags from fixture', () => {
      const result = sanitizeHtml(resourcesCrashHtml);
      
      // The fixture has 3 picture elements, each with one img
      const imgCount = (result.match(/<img/gi) || []).length;
      expect(imgCount).toBe(3);
    });

    it('should preserve link structure around images', () => {
      const html = `<a href="https://example.com">
        <figure>
          <picture>
            <source srcset="test.webp">
            <img src="test.jpg" alt="Linked image">
          </picture>
        </figure>
      </a>`;
      
      const result = sanitizeHtml(html);
      expect(result).toContain('<a href="https://example.com">');
      expect(result).toContain('</a>');
      expect(result).toContain('<figure>');
      expect(result).toContain('</figure>');
      expect(result).toContain('<img');
    });

  });

  describe('img renderer tnode attribute access', () => {
    // Simulate how react-native-render-html passes tnode to custom renderers
    const resolveImageSource = (src: string | undefined | null): string | null => {
      if (!src || src.trim() === '' || src === 'about:///blank' || src.startsWith('about://')) {
        return null;
      }
      if (src.startsWith('http://') || src.startsWith('https://') || src.startsWith('data:')) {
        return src;
      }
      try {
        return new URL(src, 'https://ffci.fiveq.dev').toString();
      } catch {
        return null;
      }
    };

    // Mock renderer function matching the fixed implementation
    const imgRenderer = ({ tnode }: any) => {
      const src = tnode?.attributes?.src;
      const alt = tnode?.attributes?.alt;
      const resolvedSrc = resolveImageSource(src);
      if (!resolvedSrc) return null;
      return { uri: resolvedSrc, alt };
    };

    it('should extract src from tnode.attributes (correct approach)', () => {
      const mockTnode = {
        attributes: {
          src: 'https://example.com/image.jpg',
          alt: 'Test image'
        }
      };

      const result = imgRenderer({ tnode: mockTnode });
      expect(result).toEqual({
        uri: 'https://example.com/image.jpg',
        alt: 'Test image'
      });
    });

    it('should return null when tnode.attributes.src is missing', () => {
      const mockTnode = { attributes: {} };
      expect(imgRenderer({ tnode: mockTnode })).toBeNull();
    });

    it('should return null when tnode is undefined', () => {
      expect(imgRenderer({ tnode: undefined })).toBeNull();
    });

    it('OLD BUG: extracting src from props directly would fail', () => {
      // This simulates the old buggy approach that extracted src from props
      const oldBuggyRenderer = (props: any) => {
        const { src, alt } = props; // BUG: src is not directly in props!
        return src ? { uri: src, alt } : null;
      };

      // The tnode structure - src is in tnode.attributes, not in props root
      const mockProps = {
        tnode: {
          attributes: {
            src: 'https://example.com/image.jpg',
            alt: 'Test image'
          }
        }
      };

      // Old buggy renderer would return null because src is undefined
      expect(oldBuggyRenderer(mockProps)).toBeNull();
      
      // Fixed renderer works correctly
      expect(imgRenderer(mockProps)).toEqual({
        uri: 'https://example.com/image.jpg',
        alt: 'Test image'
      });
    });
  });
});
