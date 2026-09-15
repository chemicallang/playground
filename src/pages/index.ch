func MainPage(page : &mut HtmlPage) {
    #html {
        <div>
            <head>
                <meta name="description" content="Chemical is a native, memory-safe systems programming language with no garbage collection and built-in HTML/CSS macros.">
                <meta name="keywords" content="chemical, programming language, systems programming, memory safe, no gc, html macro, css macro">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            {GlobalStyles(page)}
            <style>{"""
                /* --- HERO --- */
                .hero { padding: 120px 0 88px; border-bottom: 1px solid var(--line); }
                .hero-grid {
                    display: grid;
                    grid-template-columns: minmax(0, 5fr) minmax(0, 6fr);
                    gap: 64px;
                    align-items: center;
                }
                .hero h1 {
                    font-size: clamp(2.6rem, 5.4vw, 4rem);
                    font-weight: 700;
                    letter-spacing: -0.03em;
                    margin: 22px 0 0;
                }
                .hero h1 em {
                    font-style: normal;
                    color: var(--accent);
                }
                .hero-lede {
                    color: var(--text-secondary);
                    font-size: 1.12rem;
                    line-height: 1.7;
                    max-width: 460px;
                    margin: 22px 0 0;
                }
                .hero-actions {
                    display: flex; align-items: center; gap: 12px;
                    margin-top: 34px; flex-wrap: wrap;
                }
                .hero-meta {
                    display: flex; gap: 26px; flex-wrap: wrap;
                    margin-top: 38px;
                    font-family: var(--font-mono);
                    font-size: 0.78rem;
                    color: var(--text-dim);
                }
                .hero-meta span { display: flex; align-items: center; gap: 7px; }
                .hero-meta i {
                    width: 5px; height: 5px; border-radius: 50%;
                    background: var(--accent); display: inline-block;
                }

                /* --- HERO CODE SHOWCASE --- */
                .code-window {
                    background: var(--bg-inset);
                    border: 1px solid var(--line-strong);
                    border-radius: var(--radius);
                    overflow: hidden;
                    box-shadow: 0 24px 60px -30px rgba(0, 0, 0, 0.8);
                }
                .code-window-bar {
                    display: flex; align-items: center; gap: 8px;
                    padding: 11px 16px;
                    border-bottom: 1px solid var(--line);
                    background: var(--bg-elevated);
                }
                .code-window-dot { width: 10px; height: 10px; border-radius: 50%; background: var(--line-strong); }
                .code-window-dot.on { background: var(--accent); }
                .code-window-name {
                    margin-left: auto;
                    font-family: var(--font-mono); font-size: 0.74rem;
                    color: var(--text-dim);
                }
                .code-window pre {
                    margin: 0; padding: 22px 24px;
                    font-family: var(--font-mono);
                    font-size: 0.83rem; line-height: 1.75;
                    color: var(--text-secondary);
                    overflow-x: auto;
                }
                .code-window .tk-kw { color: var(--accent); }
                .code-window .tk-fn { color: var(--text); }
                .code-window .tk-str { color: #7FD1B9; }
                .code-window .tk-cm { color: var(--text-dim); }
                body.light-theme .code-window .tk-str { color: #1F7A5C; }
                .code-window .tk-html { color: #8AB4F8; }
                body.light-theme .code-window .tk-html { color: #2C5AA0; }

                /* --- INSTALL STRIP --- */
                .install-strip { border-bottom: 1px solid var(--line); padding: 44px 0; }
                .install-inner { display: flex; align-items: center; gap: 20px; }
                .install-tabs { display: flex; gap: 2px; }
                .install-tab {
                    font-family: var(--font-mono); font-size: 0.76rem;
                    padding: 7px 14px; cursor: pointer;
                    color: var(--text-dim);
                    border: 1px solid transparent;
                    border-radius: var(--radius-sm);
                    transition: all 0.2s;
                }
                .install-tab:hover { color: var(--text); }
                .install-tab.active {
                    color: var(--accent);
                    border-color: var(--line-strong);
                    background: var(--bg-elevated);
                }
                .install-cmd-box {
                    flex: 1;
                    display: flex; align-items: center; gap: 14px;
                    background: var(--bg-inset);
                    border: 1px solid var(--line);
                    border-radius: var(--radius-sm);
                    padding: 10px 16px;
                    min-width: 0;
                }
                .install-cmd-box code {
                    font-family: var(--font-mono); font-size: 0.86rem;
                    color: var(--text);
                    flex: 1; overflow-x: auto; white-space: nowrap;
                }
                .install-cmd-box .prompt { color: var(--accent); user-select: none; }
                .copy-btn {
                    background: none; border: none; cursor: pointer;
                    font-family: var(--font-mono); font-size: 0.76rem;
                    color: var(--text-dim);
                    padding: 6px 10px; border-radius: 4px;
                    transition: all 0.2s;
                }
                .copy-btn:hover { color: var(--accent); background: var(--accent-dim); }

                /* --- FEATURES --- */
                .features-grid {
                    display: grid;
                    grid-template-columns: repeat(3, 1fr);
                    gap: 20px;
                }
                .feature-card { padding: 32px 28px; }
                .feature-num {
                    font-family: var(--font-mono); font-size: 0.74rem;
                    color: var(--accent);
                    display: block; margin-bottom: 20px;
                }
                .feature-card h3 { font-size: 1.18rem; font-weight: 600; }
                .feature-card p {
                    color: var(--text-secondary);
                    font-size: 0.95rem; line-height: 1.7;
                    margin: 12px 0 0;
                }

                /* --- EXPLORE --- */
                .explore-grid {
                    display: grid;
                    grid-template-columns: repeat(2, 1fr);
                    gap: 20px;
                }
                .nav-card {
                    display: flex; align-items: flex-start; justify-content: space-between; gap: 24px;
                    padding: 28px 30px;
                }
                .nav-card:hover { transform: translateY(-2px); }
                .nav-card h3 { font-size: 1.12rem; font-weight: 600; }
                .nav-card p {
                    color: var(--text-secondary); font-size: 0.92rem;
                    margin: 8px 0 0; max-width: 380px; line-height: 1.65;
                }
                .nav-card-arrow {
                    font-family: var(--font-mono);
                    color: var(--text-dim);
                    transition: color 0.2s, transform 0.2s;
                    align-self: center;
                    flex-shrink: 0;
                }
                .nav-card:hover .nav-card-arrow { color: var(--accent); transform: translateX(4px); }

                /* --- DOWNLOAD --- */
                .download-grid {
                    display: grid;
                    grid-template-columns: repeat(3, 1fr);
                    gap: 20px;
                }
                .os-card { padding: 28px; }
                .os-head {
                    display: flex; align-items: center; justify-content: space-between;
                    margin-bottom: 20px;
                }
                .os-head h3 { font-size: 1.05rem; font-weight: 600; }
                .os-head .arch {
                    font-family: var(--font-mono);
                    font-size: 0.74rem;
                    color: var(--text-dim);
                }
                .dl {
                    display: flex; align-items: center; justify-content: space-between;
                    padding: 11px 12px;
                    border: 1px solid var(--line);
                    border-radius: var(--radius-sm);
                    margin-top: 8px;
                    font-size: 0.86rem;
                    color: var(--text-secondary);
                    transition: all 0.2s;
                }
                .dl:hover { border-color: var(--accent); color: var(--text); }
                .dl .arch { font-family: var(--font-mono); font-size: 0.76rem; color: var(--text-dim); }

                .pre-alpha-note {
                    margin-top: 28px; text-align: center;
                    color: var(--text-dim); font-size: 0.88rem;
                }
                .pre-alpha-note a { color: var(--text-secondary); text-decoration: underline; text-underline-offset: 3px; }
                .pre-alpha-note a:hover { color: var(--accent); }

                .latest-tag {
                    margin-top: -8px; margin-bottom: 28px;
                    font-family: var(--font-mono); font-size: 0.82rem;
                    color: var(--text-dim); letter-spacing: 0.02em;
                }
                .latest-tag a { color: var(--accent); text-decoration: none; }
                .latest-tag a:hover { text-decoration: underline; text-underline-offset: 3px; }

                /* --- RESPONSIVE --- */
                @media (max-width: 980px) {
                    .hero { padding: 72px 0 56px; }
                    .hero-grid { grid-template-columns: 1fr; gap: 48px; }
                    .features-grid { grid-template-columns: 1fr; }
                    .explore-grid { grid-template-columns: 1fr; }
                    .download-grid { grid-template-columns: 1fr; }
                    .install-inner { flex-direction: column; align-items: stretch; }
                    .install-tabs { justify-content: center; }
                }
                @media (max-width: 480px) {
                    .hero { padding: 56px 0 44px; }
                    .hero h1 { font-size: clamp(2rem, 9vw, 2.6rem); }
                    .hero-lede { font-size: 1rem; }
                    .hero-actions .btn { width: 100%; }   /* full-width tap targets */
                    .install-cmd-box code { font-size: 0.78rem; }
                    .os-head .arch { display: none; }
                }
            """}</style>
            <div class="hero">
                <div class="container hero-grid">
                    <div>
                        <div class="kicker rise">Native &middot; Memory-safe &middot; No GC</div>
                        <h1 class="rise rise-1">Systems programming, <em>without the baggage.</em></h1>
                        <p class="hero-lede rise rise-2">Chemical compiles to C and runs at native speed. Memory safety without a garbage collector, and HTML/CSS as first-class citizens of the language itself.</p>
                        <div class="hero-actions rise rise-3">
                            <a href="/playground"><button class="btn btn-primary">Try the Playground</button></a>
                            <a href="https://docs.chemicallang.com" target="_blank"><button class="btn btn-ghost">Read the Docs</button></a>
                        </div>
                        <div class="hero-meta rise rise-4">
                            <span><i></i>compiles to C</span>
                            <span><i></i>zero GC pauses</span>
                            <span><i></i>HTML/CSS macros</span>
                        </div>
                    </div>
                    <div class="code-window rise rise-2">
                        <div class="code-window-bar">
                            <span class="code-window-dot on"></span>
                            <span class="code-window-dot"></span>
                            <span class="code-window-dot"></span>
                            <span class="code-window-name">main.ch</span>
                        </div>
                        <pre><span class="tk-cm">// HTML is part of the language, not a template engine</span>
<span class="tk-kw">func</span> <span class="tk-fn">Greeting</span>(page : &amp;mut HtmlPage) &#123;
    <span class="tk-kw">#html</span> &#123;
        &lt;<span class="tk-html">div</span> class=<span class="tk-str">"card"</span>&gt;
            &lt;<span class="tk-html">h1</span>&gt;Hello, Chemical!&lt;/<span class="tk-html">h1</span>&gt;
        &lt;/<span class="tk-html">div</span>&gt;
    &#125;
&#125;</pre>
                    </div>
                </div>
            </div>

            <div class="install-strip">
                <div class="container install-inner">
                    <div class="install-tabs">
                        <div class="install-tab active" onclick="selectInstallTab('bash', event)">bash</div>
                        <div class="install-tab" onclick="selectInstallTab('bash-tcc', event)">bash + tcc</div>
                        <div class="install-tab" onclick="selectInstallTab('ps', event)">powershell</div>
                        <div class="install-tab" onclick="selectInstallTab('ps-tcc', event)">pwsh + tcc</div>
                    </div>
                    <div class="install-cmd-box">
                        <span class="prompt">$</span>
                        <code id="install-cmd">curl -sSL https://chemicallang.com/install.sh | bash</code>
                        <button class="copy-btn" onclick="copyInstallCommand()">copy</button>
                    </div>
                </div>
            </div>

            <section id="features">
                <div class="container">
                    <div class="section-head">
                        <div class="kicker">Why Chemical</div>
                        <h2 class="section-title">Built for people who care about what the machine is doing.</h2>
                        <p class="section-sub">No hidden runtime, no stop-the-world pauses, no template language bolted on. What you write is what runs.</p>
                    </div>
                    <div class="features-grid">
                        <div class="card feature-card">
                            <span class="feature-num">01</span>
                            <h3>Native &amp; fast</h3>
                            <p>Compiles to C and runs via TinyCC or LLVM. Predictable, measurable performance with zero garbage-collection overhead.</p>
                        </div>
                        <div class="card feature-card">
                            <span class="feature-num">02</span>
                            <h3>Memory safe</h3>
                            <p>Ownership and borrow checking at compile time. Whole classes of bugs eliminated before the program ever runs.</p>
                        </div>
                        <div class="card feature-card">
                            <span class="feature-num">03</span>
                            <h3>Web-native macros</h3>
                            <p>HTML and CSS macros are parsed by compiler plugins, so markup is type-checked with the rest of your program.</p>
                        </div>
                    </div>
                </div>
            </section>

            <section id="explore" style="padding-top: 0;">
                <div class="container">
                    <div class="section-head">
                        <div class="kicker">Explore</div>
                        <h2 class="section-title">Everything around the language.</h2>
                    </div>
                    <div class="explore-grid">
                        <a href="https://docs.chemicallang.com" target="_blank" class="card nav-card">
                            <div>
                                <h3>Documentation</h3>
                                <p>Guides and tutorials covering syntax, memory safety, and the web macros.</p>
                            </div>
                            <span class="nav-card-arrow">&#8594;</span>
                        </a>
                        <a href="https://api.chemicallang.com" target="_blank" class="card nav-card">
                            <div>
                                <h3>API Reference</h3>
                                <p>The standard library and core modules, documented in full.</p>
                            </div>
                            <span class="nav-card-arrow">&#8594;</span>
                        </a>
                        <a href="/playground" class="card nav-card">
                            <div>
                                <h3>Playground</h3>
                                <p>Write, compile, and run Chemical in the browser. No install needed.</p>
                            </div>
                            <span class="nav-card-arrow">&#8594;</span>
                        </a>
                        <a href="https://chemicallang.github.io/components" target="_blank" class="card nav-card">
                            <div>
                                <h3>Components</h3>
                                <p>Reactive UI components built with the HTML/CSS macros, live.</p>
                            </div>
                            <span class="nav-card-arrow">&#8594;</span>
                        </a>
                    </div>
                </div>
            </section>

            <section id="download" style="padding-top: 0;">
                <div class="container">
                    <div class="section-head">
                        <div class="kicker">Get Chemical</div>
                        <h2 class="section-title">Pick your platform.</h2>
                    </div>
                    <p class="latest-tag">Latest release: <a href="https://github.com/chemicallang/chemical/releases/tag/v0.5.11" target="_blank">v0.5.11</a></p>
                    <div class="download-grid">
                        <div class="card os-card">
                            <div class="os-head"><h3>Windows</h3><span class="arch">x64 / arm64</span></div>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/windows-x64.zip"><span>x64 (LLVM)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/windows-x64-tcc.zip"><span>x64 (TinyCC)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/windows-x64-lsp.zip"><span>x64 (LSP)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/windows-arm64.zip"><span>ARM64 (LLVM)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/windows-arm64-tcc.zip"><span>ARM64 (TinyCC)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/windows-arm64-lsp.zip"><span>ARM64 (LSP)</span><span class="arch">zip</span></a>
                        </div>
                        <div class="card os-card">
                            <div class="os-head"><h3>Linux</h3><span class="arch">x64 / arm64</span></div>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/linux-x64.zip"><span>x64 (LLVM)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/linux-x64-tcc.zip"><span>x64 (TinyCC)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/linux-x64-lsp.zip"><span>x64 (LSP)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/linux-arm64.zip"><span>ARM64 (LLVM)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/linux-arm64-tcc.zip"><span>ARM64 (TinyCC)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/linux-arm64-lsp.zip"><span>ARM64 (LSP)</span><span class="arch">zip</span></a>
                        </div>
                        <div class="card os-card">
                            <div class="os-head"><h3>macOS</h3><span class="arch">Intel / Silicon</span></div>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/macos-x64.zip"><span>Intel (LLVM)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/macos-x64-tcc.zip"><span>Intel (TinyCC)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/macos-x64-lsp.zip"><span>Intel (LSP)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/macos-arm64.zip"><span>Apple Silicon (LLVM)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/macos-arm64-tcc.zip"><span>Apple Silicon (TinyCC)</span><span class="arch">zip</span></a>
                            <a class="dl" href="https://github.com/chemicallang/chemical/releases/download/v0.5.11/macos-arm64-lsp.zip"><span>Apple Silicon (LSP)</span><span class="arch">zip</span></a>
                        </div>
                    </div>
                    <p class="pre-alpha-note">Chemical is in <strong style="color:var(--text-secondary);">pre-alpha</strong>. More builds on <a href="https://github.com/chemicallang/chemical/releases" target="_blank">GitHub Releases</a>.</p>
                </div>
            </section>

            {Footer(page)}

            <script>{"""
                // --- INSTALL COMMANDS ---
                function copyInstallCommand() {
                    const cmd = document.getElementById('install-cmd').textContent;
                    if (!cmd) return;
                    navigator.clipboard.writeText(cmd).then(() => {
                        const btn = document.querySelector('.copy-btn');
                        const originalText = btn.textContent;
                        btn.textContent = 'copied';
                        setTimeout(() => {
                            btn.textContent = originalText;
                        }, 1600);
                    });
                }

                const installCommands = {
                    'bash': {
                        cmd: 'curl -sSL https://chemicallang.com/install.sh | bash'
                    },
                    'bash-tcc': {
                        cmd: "curl -sSL https://chemicallang.com/install.sh | VARIANT='tcc' bash"
                    },
                    'ps': {
                        cmd: 'iwr https://chemicallang.com/install.ps1 | iex'
                    },
                    'ps-tcc': {
                        cmd: "$env:VARIANT='tcc'; iwr https://chemicallang.com/install.ps1 | iex"
                    }
                };

                function selectInstallTab(tabId, event) {
                    document.querySelectorAll('.install-tab').forEach(chip => chip.classList.remove('active'));
                    event.currentTarget.classList.add('active');
                    const info = installCommands[tabId];
                    document.getElementById('install-cmd').textContent = info.cmd;
                }

                // --- SCROLL REVEAL ---
                document.querySelectorAll('section .card, section .section-head').forEach(el => {
                    el.style.animation = 'none';
                    el.style.opacity = '0';
                    const io = new IntersectionObserver((es) => {
                        es.forEach(e => {
                            if (e.isIntersecting) {
                                el.style.animation = 'rise 0.7s cubic-bezier(0.22, 1, 0.36, 1) both';
                                el.style.opacity = '1';
                                io.unobserve(el);
                            }
                        });
                    }, { threshold: 0.12 });
                    io.observe(el);
                });
            """}</script>
        </div>
    }
}
