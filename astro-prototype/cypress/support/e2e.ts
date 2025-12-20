import './commands';

// Hide Astro dev bar that can interfere with tests
Cypress.on('window:before:load', (win) => {
  // Inject CSS to hide dev bar before page loads
  const style = win.document.createElement('style');
  style.textContent = `
    #dev-bar-hitbox-above,
    #dev-bar,
    astro-dev-toolbar {
      display: none !important;
      visibility: hidden !important;
      opacity: 0 !important;
      pointer-events: none !important;
    }
  `;
  win.document.head.appendChild(style);
});
