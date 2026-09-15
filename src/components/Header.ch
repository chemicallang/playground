func Header(page : &mut HtmlPage) {
    #html {
        <header>
          <script>{"""
            function toggleTheme() {
                document.body.classList.toggle('light-theme');
                const isLight = document.body.classList.contains('light-theme');
                localStorage.setItem('theme', isLight ? 'light' : 'dark');
            }
            // Check local storage or preference immediately to avoid flash
            const savedTheme = localStorage.getItem('theme');
            if (savedTheme === 'light') {
                document.body.classList.add('light-theme');
            }
          """}</script>
          <div class="container nav">
            <a href="/" class="logo"><img src="/Logo.png" alt="Chemical logo"/><span>Chemical</span></a>
            <nav class="nav-links">
              <a href="https://docs.chemicallang.com" target="_blank" class="nav-link">Docs</a>
              <a href="https://github.com/chemicallang/chemical" target="_blank" class="nav-link">GitHub</a>
              <a href="https://chemicallang.github.io/components" target="_blank" class="nav-link">Components</a>
              <button class="theme-toggle" onclick="toggleTheme()" title="Toggle theme" aria-label="Toggle theme">
                  <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                      <circle cx="12" cy="12" r="4.5"></circle>
                      <line x1="12" y1="2" x2="12" y2="4.5"></line>
                      <line x1="12" y1="19.5" x2="12" y2="22"></line>
                      <line x1="2" y1="12" x2="4.5" y2="12"></line>
                      <line x1="19.5" y1="12" x2="22" y2="12"></line>
                      <line x1="4.93" y1="4.93" x2="6.7" y2="6.7"></line>
                      <line x1="17.3" y1="17.3" x2="19.07" y2="19.07"></line>
                      <line x1="4.93" y1="19.07" x2="6.7" y2="17.3"></line>
                      <line x1="17.3" y1="6.7" x2="19.07" y2="4.93"></line>
                  </svg>
              </button>
              <a href="/playground"><button class="btn btn-primary btn-nav">Playground</button></a>
            </nav>
          </div>
        </header>
    }
}
