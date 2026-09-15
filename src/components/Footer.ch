func Footer(page : &mut HtmlPage) {
    #html {
        <footer>
          <div class="container">
            <div class="footer-grid">
              <div class="footer-brand">
                <a href="/" class="logo"><img src="/Logo.png" alt="Chemical logo"/><span>Chemical</span></a>
                <p>A native, memory-safe systems programming language with HTML/CSS macros and no garbage collector.</p>
              </div>
              <div class="footer-col">
                <h4>Learn</h4>
                <a href="https://docs.chemicallang.com" target="_blank">Documentation</a>
                <a href="https://api.chemicallang.com" target="_blank">API Reference</a>
                <a href="/playground">Playground</a>
              </div>
              <div class="footer-col">
                <h4>Ecosystem</h4>
                <a href="https://github.com/chemicallang/chemical" target="_blank">GitHub</a>
                <a href="https://chemicallang.github.io/components" target="_blank">Components</a>
                <a href="https://github.com/chemicallang/chemical/releases" target="_blank">Releases</a>
              </div>
              <div class="footer-col">
                <h4>Install</h4>
                <a href="/install.sh">install.sh</a>
                <a href="/install.ps1">install.ps1</a>
                <a href="https://docs.chemicallang.com" target="_blank">Quick start</a>
              </div>
            </div>
            <div class="footer-bottom">
              <span>&copy; 2026 Chemical Language. Crafted for the modern era.</span>
              <span class="mono">no gc &middot; native speed &middot; html in the language</span>
            </div>
          </div>
        </footer>
    }
}
