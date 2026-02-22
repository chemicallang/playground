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
                #bg-canvas {
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    z-index: -1;
                    opacity: 0.5;
                }
                body:not(.light-theme) #bg-canvas {
                    background: radial-gradient(circle at 50% 50%, #0f172a 0%, #020617 100%);
                }
                body.light-theme #bg-canvas {
                    background: radial-gradient(circle at 50% 50%, #f1f5f9 0%, #ffffff 100%);
                }

                .install-box {
                    max-width: 600px;
                    margin: 3rem auto 0 auto;
                    background: var(--surface);
                    border: 1px solid var(--border-color);
                    border-radius: var(--border-radius);
                    padding: 1.5rem;
                    text-align: left;
                    box-shadow: var(--shadow-strong);
                }

                .install-tabs {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 0.5rem;
                    margin-bottom: 1.25rem;
                }

                .tab-chip {
                    padding: 0.5rem 1rem;
                    background: var(--bg);
                    border: 1px solid var(--border-color);
                    border-radius: 20px;
                    color: var(--text-muted);
                    font-size: 0.85rem;
                    font-weight: 600;
                    cursor: pointer;
                    transition: all var(--transition);
                }

                .tab-chip:hover {
                    background: var(--muted-surface);
                    color: var(--text);
                }

                .tab-chip.active {
                    background: var(--accent-primary);
                    border-color: var(--accent-primary);
                    color: var(--accent-contrast);
                }

                .install-command {
                    background: var(--bg);
                    border: 1px solid var(--border-color);
                    border-radius: 10px;
                    padding: 0.85rem 1rem;
                    font-family: monospace;
                    font-size: 0.9rem;
                    color: var(--accent-primary);
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    gap: 1rem;
                    transition: all var(--transition);
                }

                .install-command:hover {
                    border-color: var(--accent-primary);
                }

                .install-command code {
                    flex: 1;
                    user-select: all;
                }

                .copy-btn {
                    background: var(--surface);
                    border: 1px solid var(--accent-primary);
                    color: var(--accent-primary);
                    padding: 0.4rem 0.85rem;
                    border-radius: 6px;
                    font-size: 0.8rem;
                    font-weight: 600;
                    cursor: pointer;
                    transition: all var(--transition);
                    white-space: nowrap;
                }

                .copy-btn:hover {
                    background: var(--accent-primary);
                    color: var(--accent-contrast);
                }

                .install-label {
                    font-size: 0.75rem;
                    color: var(--text-muted);
                    margin-top: 0.75rem;
                    font-weight: 500;
                    text-align: center;
                }

                /* Explore Section Styles */
                .nav-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                    gap: 1.5rem;
                    margin-top: 2.5rem;
                }

                .nav-card {
                    background: var(--surface);
                    border: 1px solid var(--border-color);
                    padding: 2rem;
                    border-radius: var(--border-radius);
                    text-decoration: none;
                    color: var(--text);
                    transition: all var(--transition);
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                }

                .nav-card:hover {
                    transform: translateY(-8px);
                    border-color: var(--accent-primary);
                    background: var(--muted-surface);
                    box-shadow: var(--shadow-strong);
                }

                .nav-card-icon {
                    font-size: 2.5rem;
                    line-height: 1;
                }

                .nav-card h3 {
                    font-size: 1.5rem;
                    font-weight: 700;
                    margin: 0;
                    display: flex;
                    align-items: center;
                    gap: 0.75rem;
                }

                .nav-card p {
                    color: var(--text-muted);
                    font-size: 1rem;
                    line-height: 1.6;
                    margin: 0;
                }

                .nav-card-badge {
                    display: inline-block;
                    padding: 0.25rem 0.75rem;
                    background: var(--glow-color);
                    border: 1px solid var(--accent-primary);
                    border-radius: 6px;
                    font-size: 0.75rem;
                    font-weight: 600;
                    color: var(--accent-primary);
                    text-transform: uppercase;
                    letter-spacing: 0.05em;
                    align-self: flex-start;
                }

                /* Beautified Download Section */
                .os-card {
                    background: var(--surface);
                    border: 1px solid var(--border-color);
                    border-radius: var(--border-radius);
                    transition: all var(--transition) !important;
                }
                .os-card:hover {
                    transform: translateY(-8px) scale(1.02);
                    border-color: var(--accent-primary);
                    box-shadow: var(--shadow-strong);
                }
                .download-link {
                    background: var(--bg);
                    border: 1px solid var(--border-color);
                    border-radius: var(--border-radius);
                    transition: all var(--transition) !important;
                }
                .download-link:hover {
                    background: var(--muted-surface);
                    border-color: var(--accent-primary);
                    color: var(--accent-primary);
                }
            """}</style>
            <canvas id="bg-canvas"></canvas>
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

                    <div class="install-box fade-in delay-300">
                        <div class="install-tabs">
                            <div class="tab-chip active" onclick="selectInstallTab('bash', event)">Bash</div>
                            <div class="tab-chip" onclick="selectInstallTab('bash-tcc', event)">Bash (TCC)</div>
                            <div class="tab-chip" onclick="selectInstallTab('ps', event)">PowerShell</div>
                            <div class="tab-chip" onclick="selectInstallTab('ps-tcc', event)">PowerShell (TCC)</div>
                        </div>
                        <div class="install-command">
                            <code id="install-cmd">curl -sSL https://chemicallang.com/install.sh | bash</code>
                            <button class="copy-btn" onclick="copyInstallCommand()">Copy</button>
                        </div>
                        <div class="install-label" id="install-label">Quick Install (Unix/Linux/macOS)</div>
                    </div>
                </div>
            </div>

            <div class="container">
                <section id="features">
                    <h2 class="section-title">What is Chemical?</h2>
                    <div class="features-grid">
                        <div class="feature-card fade-in delay-100">
                            <h3>Native & Fast</h3>
                            <p>Compiles to C and runs via TinyCC or LLVM. No garbage collection means predictable performance.</p>
                        </div>
                        <div class="feature-card fade-in delay-300">
                            <h3>Macro Power</h3>
                            <p>First-class support for HTML and CSS macros, parsed by compiler plugins for safe web development.</p>
                        </div>
                        <div class="feature-card fade-in delay-300">
                            <h3>Flexible Build</h3>
                            <p>Built-in build system that handles dependencies and compilation efficiently.</p>
                        </div>
                    </div>
                </section>

                <section id="explore">
                    <h2 class="section-title">Explore Chemical</h2>
                    <div class="nav-grid">
                        <a href="https://docs.chemicallang.com" class="nav-card">
                            <div class="nav-card-icon">📖</div>
                            <h3>Documentation</h3>
                            <p>Complete guides, tutorials, and reference materials to get you started with Chemical.</p>
                        </a>

                        <a href="https://chemicallang.com/api" class="nav-card">
                            <div class="nav-card-icon">📚</div>
                            <h3>API Reference</h3>
                            <p>Comprehensive API documentation for Chemical's standard library and core functionality.</p>
                        </a>

                        <a href="/playground" class="nav-card">
                            <div class="nav-card-icon">🎮</div>
                            <h3>Playground</h3>
                            <p>Write, compile, and run Chemical code directly in your browser. Experiment with the language.</p>
                            <span class="nav-card-badge">Interactive</span>
                        </a>

                        <a href="https://chemicallang.github.io/components" class="nav-card">
                            <div class="nav-card-icon">🧩</div>
                            <h3>Components Showcase</h3>
                            <p>Explore UI components built with Chemical's HTML/CSS macros. Reactive web interfaces.</p>
                            <span class="nav-card-badge">Demo</span>
                        </a>
                    </div>
                </section>

                <section id="download">
                    <h2 class="section-title">Download Compiler (v0.0.30)</h2>
                    <div class="download-grid">
                        <!-- Windows -->
                        <div class="os-card">
                            <h3>Windows</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/windows-x64.zip" class="download-link">
                                    <span class="arch">x64 (LLVM)</span>
                                    <span class="desc">Default Backend</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/windows-x64-tcc.zip" class="download-link">
                                    <span class="arch">x64 (TinyCC)</span>
                                    <span class="desc">Fast Compilation</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/windows-arm64.zip" class="download-link">
                                    <span class="arch">ARM64 (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/windows-arm64-tcc.zip" class="download-link">
                                    <span class="arch">ARM64 (TinyCC)</span>
                                </a>
                            </div>
                        </div>

                        <!-- Linux -->
                        <div class="os-card">
                            <h3>Linux</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/linux-x64.zip" class="download-link">
                                    <span class="arch">x64 (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/linux-x64-tcc.zip" class="download-link">
                                    <span class="arch">x64 (TinyCC)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/linux-arm64.zip" class="download-link">
                                    <span class="arch">ARM64 (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/linux-arm64-tcc.zip" class="download-link">
                                    <span class="arch">ARM64 (TinyCC)</span>
                                </a>
                            </div>
                        </div>

                        <!-- macOS -->
                        <div class="os-card">
                            <h3>macOS</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/macos-x64.zip" class="download-link">
                                    <span class="arch">Intel (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/macos-x64-tcc.zip" class="download-link">
                                    <span class="arch">Intel (TinyCC)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/macos-arm64.zip" class="download-link">
                                    <span class="arch">Apple Silicon (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.30/macos-arm64-tcc.zip" class="download-link">
                                    <span class="arch">Apple Silicon (TinyCC)</span>
                                </a>
                            </div>
                        </div>
                    </div>
                    <p class="note">Chemical is currently in <strong>Pre-Alpha</strong>. Alpine Linux versions are also available on <a href="https://github.com/chemicallang/chemical/releases/tag/v0.0.30" target="_blank" style="text-decoration:underline;">GitHub Releases</a>.</p>
                </section>
            </div>

            {Footer(page)}

            <script>{"""
                // --- INSTALL COMMANDS LOGIC ---
                function copyInstallCommand() {
                    const cmd = document.getElementById('install-cmd').textContent;
                    if (!cmd) return;
                    navigator.clipboard.writeText(cmd).then(() => {
                        const btn = document.querySelector('.copy-btn');
                        const originalText = btn.textContent;
                        btn.textContent = 'Copied!';
                        setTimeout(() => {
                            btn.textContent = originalText;
                        }, 2000);
                    });
                }

                const installCommands = {
                    'bash': {
                        label: 'Quick Install (Unix/Linux/macOS)',
                        cmd: 'curl -sSL https://chemicallang.com/install.sh | bash'
                    },
                    'bash-tcc': {
                        label: 'Quick Install (TCC Variant - Unix/Linux/macOS)',
                        cmd: "curl -sSL https://chemicallang.com/install.sh | VARIANT='tcc' bash"
                    },
                    'ps': {
                        label: 'Quick Install (Windows PowerShell)',
                        cmd: 'iwr https://chemicallang.com/install.ps1 | iex'
                    },
                    'ps-tcc': {
                        label: 'Quick Install (TCC Variant - Windows PowerShell)',
                        cmd: "$env:VARIANT='tcc'; iwr https://chemicallang.com/install.ps1 | iex"
                    }
                };

                function selectInstallTab(tabId, event) {
                    document.querySelectorAll('.tab-chip').forEach(chip => chip.classList.remove('active'));
                    event.currentTarget.classList.add('active');
                    const info = installCommands[tabId];
                    document.getElementById('install-label').textContent = info.label;
                    document.getElementById('install-cmd').textContent = info.cmd;
                }

                // --- BACKGROUND PARTICLES ANIMATION ---
                const canvas = document.getElementById('bg-canvas');
                const ctx = canvas.getContext('2d');
                let particles = [];
                const particleCount = 60;
                const maxDistance = 150;

                function resize() {
                    canvas.width = window.innerWidth;
                    canvas.height = window.innerHeight;
                }
                window.addEventListener('resize', resize);
                resize();

                class Particle {
                    constructor() { this.init(); }
                    init() {
                        this.x = Math.random() * canvas.width;
                        this.y = Math.random() * canvas.height;
                        this.vx = (Math.random() - 0.5) * 0.5;
                        this.vy = (Math.random() - 0.5) * 0.5;
                        this.radius = Math.random() * 2 + 1;
                    }
                    update() {
                        this.x += this.vx;
                        this.y += this.vy;
                        if (this.x < 0 || this.x > canvas.width) this.vx *= -1;
                        if (this.y < 0 || this.y > canvas.height) this.vy *= -1;
                    }
                    draw() {
                        ctx.beginPath();
                        ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
                        const isLight = document.body.classList.contains('light-theme');
                        ctx.fillStyle = isLight ? 'rgba(37, 99, 235, 0.2)' : 'rgba(56, 189, 248, 0.3)';
                        ctx.fill();
                    }
                }

                for (let i = 0; i < particleCount; i++) particles.push(new Particle());

                function animate() {
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                    const isLight = document.body.classList.contains('light-theme');
                    for (let i = 0; i < particles.length; i++) {
                        particles[i].update();
                        particles[i].draw();
                        for (let j = i + 1; j < particles.length; j++) {
                            const dx = particles[i].x - particles[j].x;
                            const dy = particles[i].y - particles[j].y;
                            const dist = Math.sqrt(dx * dx + dy * dy);
                            if (dist < maxDistance) {
                                ctx.beginPath();
                                ctx.moveTo(particles[i].x, particles[i].y);
                                ctx.lineTo(particles[j].x, particles[j].y);
                                const opacity = 0.15 * (1 - dist / maxDistance);
                                ctx.strokeStyle = isLight ? `rgba(37, 99, 235, ${opacity})` : `rgba(56, 189, 248, ${opacity})`;
                                ctx.lineWidth = 1;
                                ctx.stroke();
                            }
                        }
                    }
                    requestAnimationFrame(animate);
                }
                animate();
            """}</script>
        </div>
    }
}
