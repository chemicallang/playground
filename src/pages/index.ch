import "@html/page.ch"

func MainPage(page : &mut HtmlPage) {
    #html {
        <div>
            {GlobalStyles(page)}
            {Header(page)}

            <!-- Hero -->
            <section class="hero container">
              <div class="hero-content">
                <h1>Chemical Programming Language</h1>
                <p>Experience compile-time safety, blazing performance, and seamless modularity-all in a sleek, modern interface.</p>
                <div class="buttons">
                  <a href="https://github.com/chemicallang/chemical/releases" target="_blank"><button class="btn btn-primary">Download</button></a>
                  <a href="https://github.com/chemicallang/chemical" target="_blank"><button class="btn btn-secondary">View on GitHub</button></a>
                  <a href="https://discord.gg/RTsJgmXmXC" target="_blank"><button class="btn btn-secondary">Discord</button></a>
                </div>
              </div>
            </section>

            {Footer(page)}
        </div>
    }
}