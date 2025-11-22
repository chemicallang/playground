import "@html/page.ch"

func MainPage(page : &mut HtmlPage) {
    #html {
        <div>
            <!-- 
            <meta name="description" content="Chemical is a native, memory-safe systems programming language with no garbage collection and built-in HTML/CSS macros.">
            <meta name="keywords" content="chemical, programming language, systems programming, memory safe, no gc, html macro, css macro">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            -->

            {GlobalStyles(page)}
            {Header(page)}
            <div class="hero">
                <div class="hero-content">
                    <h1 class="fade-in">The Chemical Programming Language</h1>
                    <p class="fade-in delay-100">A native, memory-safe systems language with HTML/CSS macros and no garbage collection.</p>
                    <div class="buttons fade-in delay-200">
                        <a href="/playground" class="btn btn-primary">Try Playground</a>
                        <a href="https://github.com/chemicallang/chemical" target="_blank" class="btn btn-secondary github-link">
                            <svg height="20" width="20" viewBox="0 0 16 16" version="1.1" aria-hidden="true"><path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path></svg>
                            GitHub
                        </a>
                    </div>
                </div>
            </div>

            <div class="container">
                <section id="features">
                    <h2 class="section-title">What is Chemical?</h2>
                    <div class="features-grid">
                        <div class="feature-card fade-in delay-100">
                            <div class="icon-box">⚡</div>
                            <h3>Native & Fast</h3>
                            <p>Compiles to C and runs via TinyCC or LLVM. No garbage collection means predictable performance.</p>
                        </div>
                        <div class="feature-card fade-in delay-200">
                            <div class="icon-box">🛡️</div>
                            <h3>Memory Safe</h3>
                            <p>Designed with memory safety goals to prevent common errors without the overhead of a GC.</p>
                        </div>
                        <div class="feature-card fade-in delay-300">
                            <div class="icon-box">🎨</div>
                            <h3>Macro Power</h3>
                            <p>First-class support for HTML and CSS macros, parsed by compiler plugins for safe web development.</p>
                        </div>
                        <div class="feature-card fade-in delay-300">
                            <div class="icon-box">📦</div>
                            <h3>Flexible Build</h3>
                            <p>Built-in build system that handles dependencies and compilation efficiently.</p>
                        </div>
                    </div>
                    <p class="note">Chemical is currently in <strong>Pre-Alpha</strong>. Expect breaking changes and experimental features.</p>
                </section>

                <section id="download">
                    <h2 class="section-title">Download Compiler (v0.0.26)</h2>
                    <div class="download-grid">
                        <!-- Windows -->
                        <div class="os-card">
                            <div class="os-icon">🪟</div>
                            <h3>Windows</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/windows-x64.zip" class="download-link">
                                    <span class="arch">x64 (LLVM)</span>
                                    <span class="desc">Default Backend</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/windows-x64-tcc.zip" class="download-link">
                                    <span class="arch">x64 (TinyCC)</span>
                                    <span class="desc">Fast Compilation</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/windows-arm64.zip" class="download-link">
                                    <span class="arch">ARM64 (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/windows-arm64-tcc.zip" class="download-link">
                                    <span class="arch">ARM64 (TinyCC)</span>
                                </a>
                            </div>
                        </div>

                        <!-- Linux -->
                        <div class="os-card">
                            <div class="os-icon">🐧</div>
                            <h3>Linux</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-x64.zip" class="download-link">
                                    <span class="arch">x64 (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-x64-tcc.zip" class="download-link">
                                    <span class="arch">x64 (TinyCC)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-arm64.zip" class="download-link">
                                    <span class="arch">ARM64 (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-arm64-tcc.zip" class="download-link">
                                    <span class="arch">ARM64 (TinyCC)</span>
                                </a>
                            </div>
                        </div>

                        <!-- macOS -->
                        <div class="os-card">
                            <div class="os-icon">🍎</div>
                            <h3>macOS</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-x64.zip" class="download-link">
                                    <span class="arch">Intel (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/macos-x64-tcc.zip" class="download-link">
                                    <span class="arch">Intel (TinyCC)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/macos-arm64.zip" class="download-link">
                                    <span class="arch">Apple Silicon (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/macos-arm64-tcc.zip" class="download-link">
                                    <span class="arch">Apple Silicon (TinyCC)</span>
                                </a>
                            </div>
                        </div>
                    </div>
                    <p class="note">Alpine Linux versions are also available on <a href="https://github.com/chemicallang/chemical/releases/tag/v0.0.26" target="_blank" style="text-decoration:underline;">GitHub Releases</a>.</p>
                </section>
            </div>

            {Footer(page)}
        </div>
    }
}