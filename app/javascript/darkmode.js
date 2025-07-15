// Dark mode toggle functionality - Simple and reliable
(function() {
  function initializeDarkMode() {
    const currentTheme = localStorage.getItem('theme') || 'light';
    
    if (currentTheme === 'dark') {
      document.documentElement.classList.add('dark');
      updateThemeIcon('dark');
    } else {
      document.documentElement.classList.remove('dark');
      updateThemeIcon('light');
    }
  }

  function updateThemeIcon(theme) {
    const sunIcon = document.getElementById('theme-icon-sun');
    const moonIcon = document.getElementById('theme-icon-moon');
    
    if (sunIcon && moonIcon) {
      if (theme === 'dark') {
        sunIcon.style.display = 'none';
        moonIcon.style.display = 'block';
      } else {
        sunIcon.style.display = 'block';
        moonIcon.style.display = 'none';
      }
    }
  }

  // Global toggle function
  window.toggleDarkMode = function() {
    const html = document.documentElement;
    const isDark = html.classList.contains('dark');
    
    if (isDark) {
      html.classList.remove('dark');
      localStorage.setItem('theme', 'light');
      updateThemeIcon('light');
    } else {
      html.classList.add('dark');
      localStorage.setItem('theme', 'dark');
      updateThemeIcon('dark');
    }
  };

  // Initialize immediately
  initializeDarkMode();
  
  // Also initialize on these events
  document.addEventListener('DOMContentLoaded', initializeDarkMode);
  document.addEventListener('turbo:load', initializeDarkMode);
})();