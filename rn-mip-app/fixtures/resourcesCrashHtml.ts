// Minimal HTML fixture that mirrors the Resources page structure which triggers
// the current crash in react-native-render-html. It keeps the nested
// <a><figure><div><picture><source><img> pattern with multiple <source> tags.
export const resourcesCrashHtml = `
<div class="_background" style=" --overlayDisplay: none; --imageBlur: 0px; --imageBlendmode: soft-light; --bgColor: #111;">
  <picture style="opacity: 0.7;">
    <source srcset="https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=2000" media="(min-width: 1024px)" type="image/webp">
    <source srcset="https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=1400" media="(min-width: 768px)" type="image/webp">
    <source srcset="https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=950" media="(min-width: 480px)" type="image/webp">
    <source srcset="https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=800" media="(min-width: 2px)" type="image/webp">
    <img
      fetchpriority="high"
      preload="eager"
      src="https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48"
      srcset="https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=2000 1600w, https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=1400 1200w, https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=950 950w, https://ffci-5q.b-cdn.net/image/pexels-pixabay-266403.jpg?crop=2000,858,0,48&width=800 800w"
      width="2000"
      height="1125"
      alt="black and white image of firemen with hoses"
      style="opacity: 0.7; max-width: 100%; height: 100%;"
    >
  </picture>
</div>

<a class="_image-link" href="https://harvest.org/know-god/how-to-know-god/">
  <figure class="_image w-full flex flex-col items-center">
    <div class="w-full">
      <picture>
        <source srcset="https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0&width=1600" media="(min-width: 1280px)" type="image/webp">
        <source srcset="https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0&width=800" media="(min-width: 1024px)" type="image/webp">
        <source srcset="https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0&width=700" media="(min-width: 768px)" type="image/webp">
        <source srcset="https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0&width=400" media="(min-width: 2px)" type="image/webp">
        <img
          loading="lazy"
          src="https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0"
          srcset="https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0&width=1600 1600w, https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0&width=800 800w, https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0&width=700 700w, https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=1680,1120,191,0&width=400 400w"
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
        <source srcset="https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0&width=1600" media="(min-width: 1280px)" type="image/webp">
        <source srcset="https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0&width=800" media="(min-width: 1024px)" type="image/webp">
        <source srcset="https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0&width=700" media="(min-width: 768px)" type="image/webp">
        <source srcset="https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0&width=400" media="(min-width: 2px)" type="image/webp">
        <img
          loading="lazy"
          src="https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0"
          srcset="https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0&width=1600 1600w, https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0&width=800 800w, https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0&width=700 700w, https://ffci-5q.b-cdn.net/image/rp2bbncw.jpg?crop=1995,1330,3,0&width=400 400w"
          width="800"
          height="532"
          alt="Man reading a Bible"
        >
      </picture>
    </div>
  </figure>
</a>
`;
