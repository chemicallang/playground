func Header(page : &mut HtmlPage) {
    #html {
        <!-- Header & Nav -->
        <header>
          <div class="container nav">
            <a href="/" class="logo"><img src="/Logo.png" alt="Logo" height="48px"/>Chemical</a>
            <nav class="nav-links">
              <button class="theme-toggle" onclick="toggleTheme()" title="Toggle Theme">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <circle cx="12" cy="12" r="5"></circle>
                      <line x1="12" y1="1" x2="12" y2="3"></line>
                      <line x1="12" y1="21" x2="12" y2="23"></line>
                      <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                      <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                      <line x1="1" y1="12" x2="3" y2="12"></line>
                      <line x1="21" y1="12" x2="23" y2="12"></line>
                      <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                      <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
                  </svg>
              </button>
              <a href="https://chemicallang.github.io/learn-chemical" target="_blank"><button class="btn btn-primary">Get Started</button></a>
              <a href="/playground"><button class="btn btn-primary">Playground</button></a>
            </nav>
          </div>
        </header>
    }
}