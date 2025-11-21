import "@html/page.ch"

func MainPage(page : &mut HtmlPage) {
    #html {
        <div>
            {GlobalStyles(page)}
            {Header(page)}
            <div class="hero">
                <div class="hero-content">
                    <h1>The Chemical Programming Language</h1>
                    <p>A native, memory-safe systems language with HTML/CSS macros and no garbage collection.</p>
                    <div class="buttons">
                        <a href="/playground" class="btn btn-primary">Try Playground</a>
                        <a href="https://github.com/chemicallang/chemical" target="_blank" class="btn btn-secondary github-link">
                            <img src="/assets/github-mark.svg" style="width:20px;height:20px;filter:invert(1);" alt=""> GitHub
                        </a>
                    </div>
                </div>
            </div>

            <div class="container">
                <section id="features">
                    <h2 class="section-title">What is Chemical?</h2>
                    <div class="features-grid">
                        <div class="feature-card">
                            <h3>Native & Fast</h3>
                            <p>Compiles to C and runs via TinyCC or LLVM. No garbage collection means predictable performance.</p>
                        </div>
                        <div class="feature-card">
                            <h3>Memory Safe</h3>
                            <p>Designed with memory safety goals to prevent common errors without the overhead of a GC.</p>
                        </div>
                        <div class="feature-card">
                            <h3>Macro Power</h3>
                            <p>First-class support for HTML and CSS macros, parsed by compiler plugins for safe web development.</p>
                        </div>
                        <div class="feature-card">
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
                            <h3>Windows</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/windows-x64.zip" class="download-link">
                                    x64 (LLVM) <span>Default Backend</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/windows-x64-tcc.zip" class="download-link">
                                    x64 (TinyCC) <span>Fast Compilation</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/windows-arm64.zip" class="download-link">
                                    ARM64 (LLVM)
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/windows-arm64-tcc.zip" class="download-link">
                                    ARM64 (TinyCC)
                                </a>
                            </div>
                        </div>

                        <!-- Linux -->
                        <div class="os-card">
                            <h3>Linux</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-x64.zip" class="download-link">
                                    x64 (LLVM)
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-x64-tcc.zip" class="download-link">
                                    x64 (TinyCC)
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-arm64.zip" class="download-link">
                                    ARM64 (LLVM)
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-arm64-tcc.zip" class="download-link">
                                    ARM64 (TinyCC)
                                </a>
                            </div>
                        </div>

                        <!-- macOS -->
                        <div class="os-card">
                            <h3>macOS</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/linux-x64.zip" class="download-link">
                                    Intel (LLVM)
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/macos-x64-tcc.zip" class="download-link">
                                    Intel (TinyCC)
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/macos-arm64.zip" class="download-link">
                                    Apple Silicon (LLVM)
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.26/macos-arm64-tcc.zip" class="download-link">
                                    Apple Silicon (TinyCC)
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