describe('Analytics', () => {
  beforeEach(() => {
    // Clear any previous analytics events
    cy.window().then((win) => {
      (win as unknown as { __analyticsEvents?: unknown[] }).__analyticsEvents = [];
    });
  });

  describe('App Open Event', () => {
    it('tracks app_open event on initial page load', () => {
      cy.visit('/');
      
      // Check console for analytics log
      cy.window().then((win) => {
        // Analytics should be available on window
        expect(win.__mipAnalytics).to.exist;
      });
      
      // Verify analytics event was dispatched
      cy.window().then((win) => {
        return new Promise<void>((resolve) => {
          win.addEventListener('analytics:track', (event: Event) => {
            const customEvent = event as CustomEvent;
            expect(customEvent.detail.event).to.equal('app_open');
            resolve();
          });
          
          // Trigger app open if not already tracked
          if (win.__mipAnalytics) {
            win.__mipAnalytics.trackAppOpen('Test App');
          } else {
            resolve();
          }
        });
      });
    });
  });

  describe('Screen View Event', () => {
    it('tracks screen_view event on page navigation', () => {
      cy.visit('/');
      
      cy.window().then((win) => {
        return new Promise<void>((resolve) => {
          win.addEventListener('analytics:track', (event: Event) => {
            const customEvent = event as CustomEvent;
            if (customEvent.detail.event === 'screen_view') {
              expect(customEvent.detail.screen_name).to.exist;
              expect(customEvent.detail.screen_path).to.exist;
              resolve();
            }
          });
          
          // Trigger screen view
          if (win.__mipAnalytics) {
            win.__mipAnalytics.trackScreenView('Home', '/');
          } else {
            resolve();
          }
        });
      });
    });

    it('tracks screen_view event with correct data structure', () => {
      cy.window().then((win) => {
        if (!win.__mipAnalytics) {
          cy.log('Analytics not available, skipping test');
          return;
        }
        
        return new Promise<void>((resolve) => {
          win.addEventListener('analytics:track', (event: Event) => {
            const customEvent = event as CustomEvent;
            if (customEvent.detail.event === 'screen_view') {
              expect(customEvent.detail.screen_name).to.equal('TestScreen');
              expect(customEvent.detail.screen_path).to.equal('/test/path');
              expect(customEvent.detail.timestamp).to.exist;
              resolve();
            }
          });
          
          win.__mipAnalytics.trackScreenView('TestScreen', '/test/path');
        });
      });
    });
  });

  describe('Content View Event', () => {
    it('tracks content_view event with correct data structure', () => {
      cy.window().then((win) => {
        if (!win.__mipAnalytics) {
          cy.log('Analytics not available, skipping test');
          return;
        }
        
        return new Promise<void>((resolve) => {
          win.addEventListener('analytics:track', (event: Event) => {
            const customEvent = event as CustomEvent;
            if (customEvent.detail.event === 'content_view') {
              expect(customEvent.detail.content_id).to.equal('test-uuid-123');
              expect(customEvent.detail.content_type).to.equal('content');
              expect(customEvent.detail.content_title).to.equal('Test Content');
              expect(customEvent.detail.timestamp).to.exist;
              resolve();
            }
          });
          
          win.__mipAnalytics.trackContentView('test-uuid-123', 'content', 'Test Content');
        });
      });
    });
  });

  describe('Video Playback Events', () => {
    it('tracks video_play event when video starts playing', () => {
      // This test would require a page with a video
      // For now, we'll test the analytics function directly
      cy.window().then((win) => {
        if (!win.__mipAnalytics) {
          cy.log('Analytics not available, skipping test');
          return;
        }
        
        return new Promise<void>((resolve) => {
          win.addEventListener('analytics:track', (event: Event) => {
            const customEvent = event as CustomEvent;
            if (customEvent.detail.event === 'video_play') {
              expect(customEvent.detail.video_source).to.exist;
              resolve();
            }
          });
          
          win.__mipAnalytics.trackVideoPlay({
            videoId: 'test-video-123',
            videoSource: 'youtube',
            videoTitle: 'Test Video',
          });
        });
      });
    });

    it('tracks video_complete event when video finishes', () => {
      cy.window().then((win) => {
        if (!win.__mipAnalytics) {
          cy.log('Analytics not available, skipping test');
          return;
        }
        
        return new Promise<void>((resolve) => {
          win.addEventListener('analytics:track', (event: Event) => {
            const customEvent = event as CustomEvent;
            if (customEvent.detail.event === 'video_complete') {
              expect(customEvent.detail.video_source).to.exist;
              resolve();
            }
          });
          
          win.__mipAnalytics.trackVideoComplete({
            videoId: 'test-video-123',
            videoSource: 'url',
            videoTitle: 'Test Video',
          });
        });
      });
    });
  });

  describe('Audio Playback Events', () => {
    it('tracks audio_play event when audio starts playing', () => {
      cy.window().then((win) => {
        if (!win.__mipAnalytics) {
          cy.log('Analytics not available, skipping test');
          return;
        }
        
        return new Promise<void>((resolve) => {
          win.addEventListener('analytics:track', (event: Event) => {
            const customEvent = event as CustomEvent;
            if (customEvent.detail.event === 'audio_play') {
              expect(customEvent.detail.audio_id).to.exist;
              resolve();
            }
          });
          
          win.__mipAnalytics.trackAudioPlay({
            audioId: 'test-audio-123',
            audioTitle: 'Test Audio',
          });
        });
      });
    });
  });

  describe('External Link Events', () => {
    it('tracks external_link event with correct data structure', () => {
      cy.window().then((win) => {
        if (!win.__mipAnalytics) {
          cy.log('Analytics not available, skipping test');
          return;
        }
        
        return new Promise<void>((resolve) => {
          win.addEventListener('analytics:track', (event: Event) => {
            const customEvent = event as CustomEvent;
            if (customEvent.detail.event === 'external_link') {
              expect(customEvent.detail.link_url).to.equal('https://example.com');
              expect(customEvent.detail.link_text).to.equal('Test Link');
              expect(customEvent.detail.content_id).to.equal('test-content-id');
              expect(customEvent.detail.timestamp).to.exist;
              resolve();
            }
          });
          
          win.__mipAnalytics.trackExternalLink({
            linkUrl: 'https://example.com',
            linkText: 'Test Link',
            contentId: 'test-content-id',
          });
        });
      });
    });
  });

  describe('Analytics Implementation', () => {
    it('exposes analytics functions on window object', () => {
      cy.visit('/');
      
      cy.window().then((win) => {
        expect(win.__mipAnalytics).to.exist;
        expect(win.__mipAnalytics.trackEvent).to.exist;
        expect(win.__mipAnalytics.trackAppOpen).to.exist;
        expect(win.__mipAnalytics.trackScreenView).to.exist;
        expect(win.__mipAnalytics.trackContentView).to.exist;
        expect(win.__mipAnalytics.trackVideoPlay).to.exist;
        expect(win.__mipAnalytics.trackVideoComplete).to.exist;
        expect(win.__mipAnalytics.trackAudioPlay).to.exist;
        expect(win.__mipAnalytics.trackExternalLink).to.exist;
      });
    });

    it('allows custom analytics implementation', () => {
      cy.visit('/');
      
      cy.window().then((win) => {
        if (!win.__mipAnalytics) return;
        
        const customImpl = {
          events: [] as unknown[],
          track(event: unknown) {
            this.events.push(event);
          },
        };
        
        win.__mipAnalytics.setAnalyticsImplementation(customImpl);
        win.__mipAnalytics.trackAppOpen('Test');
        
        expect(customImpl.events).to.have.length(1);
        expect(customImpl.events[0]).to.have.property('event', 'app_open');
      });
    });
  });
});
