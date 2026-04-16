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
                    opacity: 0.6;
                }
                body:not(.light-theme) #bg-canvas {
                    background: radial-gradient(circle at 50% 50%, #0F172A 0%, #020617 100%);
                }
                body.light-theme #bg-canvas {
                    background: radial-gradient(circle at 50% 50%, #F1F5F9 0%, #FFFFFF 100%);
                }

                /* Glassmorphic Cards & Boxes */
                .install-box, .nav-card, .os-card, .feature-card {
                    background: var(--glass-bg);
                    border: 1px solid var(--glass-border);
                    backdrop-filter: var(--glass-blur);
                    -webkit-backdrop-filter: var(--glass-blur);
                    border-radius: var(--border-radius);
                    transition: all var(--transition);
                }

                .install-box {
                    max-width: 650px;
                    margin: 3.5rem auto 0 auto;
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
                    padding: 0.6rem 1.25rem;
                    background: rgba(255, 255, 255, 0.05);
                    border: 1px solid var(--glass-border);
                    border-radius: 30px;
                    color: var(--text-muted);
                    font-size: 0.85rem;
                    font-weight: 600;
                    cursor: pointer;
                    transition: all var(--transition);
                }

                .tab-chip:hover {
                    background: rgba(255, 255, 255, 0.1);
                    color: var(--text);
                    border-color: var(--accent-primary);
                }

                .tab-chip.active {
                    background: var(--accent-primary);
                    border-color: var(--accent-primary);
                    color: var(--accent-contrast);
                    box-shadow: 0 0 15px var(--glow-color);
                }

                .install-command {
                    background: rgba(0, 0, 0, 0.3);
                    border: 1px solid var(--glass-border);
                    border-radius: 12px;
                    padding: 1rem 1.25rem;
                    font-family: var(--font-mono);
                    font-size: 0.95rem;
                    color: var(--accent-primary);
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    gap: 1rem;
                    transition: all var(--transition);
                }

                .install-command:hover {
                    border-color: var(--accent-primary);
                    background: rgba(0, 0, 0, 0.4);
                }

                .install-command code {
                    flex: 1;
                    user-select: all;
                }

                .copy-btn {
                    background: rgba(56, 189, 248, 0.1);
                    border: 1px solid var(--accent-primary);
                    color: var(--accent-primary);
                    padding: 0.5rem 1rem;
                    border-radius: 8px;
                    font-size: 0.85rem;
                    font-weight: 700;
                    cursor: pointer;
                    transition: all var(--transition);
                    white-space: nowrap;
                }

                .copy-btn:hover {
                    background: var(--accent-primary);
                    color: var(--accent-contrast);
                    box-shadow: 0 0 12px var(--glow-color);
                }

                .install-label {
                    font-size: 0.8rem;
                    color: var(--text-muted);
                    margin-top: 1rem;
                    font-weight: 500;
                    text-align: center;
                    opacity: 0.8;
                }

                /* Hero Section Improvements */
                .hero {
                    position: relative;
                    padding: 8rem 0 6rem 0;
                    text-align: center;
                    overflow: visible;
                }

                .hero::before {
                    content: '';
                    position: absolute;
                    top: -50px;
                    left: 50%;
                    transform: translateX(-50%);
                    width: 500px;
                    height: 500px;
                    background: var(--accent-primary);
                    filter: blur(150px);
                    opacity: 0.12;
                    border-radius: 50%;
                    z-index: -1;
                    pointer-events: none;
                }

                .hero h1 {
                    font-size: clamp(2.5rem, 8vw, 5rem);
                    font-weight: 800;
                    line-height: 1.1;
                    margin-bottom: 1.5rem;
                    letter-spacing: -0.04em;
                    background: linear-gradient(to bottom, #FFFFFF 0%, #94A3B8 100%);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                }
                
                body.light-theme .hero h1 {
                    background: linear-gradient(to bottom, #0F172A 0%, #475569 100%);
                    -webkit-background-clip: text;
                }

                .hero h1 span {
                    background: var(--gradient-primary);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                }

                .hero p {
                    font-size: clamp(1.1rem, 3vw, 1.4rem);
                    color: var(--text-muted);
                    max-width: 750px;
                    margin: 0 auto 3rem auto;
                    font-weight: 400;
                    line-height: 1.6;
                }

                .hero .buttons {
                    display: flex;
                    gap: 1.25rem;
                    justify-content: center;
                    flex-wrap: wrap;
                }

                /* Navigation Cards */
                .nav-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
                    gap: 2rem;
                    margin-top: 3rem;
                }

                .nav-card {
                    padding: 2.5rem;
                    display: flex;
                    flex-direction: column;
                    gap: 1.25rem;
                    text-decoration: none;
                }

                .nav-card:hover {
                    transform: translateY(-10px);
                    border-color: var(--accent-primary);
                    background: rgba(255, 255, 255, 0.06);
                    box-shadow: var(--shadow-strong);
                }

                .nav-card-icon {
                    font-size: 3rem;
                    line-height: 1;
                    filter: drop-shadow(0 0 10px var(--glow-color));
                }

                .nav-card h3 {
                    font-size: 1.75rem;
                    font-weight: 800;
                    margin: 0;
                    display: flex;
                    align-items: center;
                    gap: 1rem;
                    letter-spacing: -0.02em;
                }

                .nav-card p {
                    color: var(--text-muted);
                    font-size: 1.05rem;
                    line-height: 1.7;
                    margin: 0;
                }

                .nav-card-badge {
                    display: inline-flex;
                    padding: 0.35rem 0.85rem;
                    background: rgba(56, 189, 248, 0.15);
                    border: 1px solid var(--accent-primary);
                    border-radius: 8px;
                    font-size: 0.75rem;
                    font-weight: 700;
                    color: var(--accent-primary);
                    text-transform: uppercase;
                    letter-spacing: 0.05em;
                    align-self: flex-start;
                }

                /* Download Cards */
                .os-card {
                    padding: 2.5rem;
                    text-align: center;
                }

                .os-card h3 {
                    font-size: 1.5rem;
                    font-weight: 800;
                    margin-bottom: 2rem;
                    color: var(--text);
                }

                .download-links {
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                }

                .download-link {
                    background: rgba(255, 255, 255, 0.03);
                    border: 1px solid var(--glass-border);
                    border-radius: 12px;
                    padding: 1.25rem;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    gap: 0.25rem;
                    color: var(--text);
                    font-weight: 600;
                    transition: all var(--transition);
                }

                .download-link:hover {
                    background: rgba(255, 255, 255, 0.08);
                    border-color: var(--accent-primary);
                    color: var(--accent-primary);
                    transform: scale(1.02);
                }

                .download-link .arch {
                    font-size: 1rem;
                }

                .download-link .desc {
                    font-size: 0.8rem;
                    color: var(--text-muted);
                    font-weight: 400;
                }

                .note {
                    text-align: center;
                    margin-top: 4rem;
                    color: var(--text-muted);
                    font-size: 1rem;
                }
                
                 .note strong { color: var(--accent-primary); }
 
                 .download-grid {
                     display: grid;
                     grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                     gap: 2rem;
                     margin-top: 2rem;
                 }
             """}</style>
            <canvas id="bg-canvas"></canvas>
            {Header(page)}
            <div class="hero">
                <div class="hero-content container">
                    <h1 class="fade-in">The <span>Chemical</span>&nbsp;Programming Language</h1>
                    <p class="fade-in delay-100">A native, memory-safe systems language with HTML/CSS macros and no garbage collection. Built for the modern web and native performance.</p>
                    <div class="buttons fade-in delay-200">
                        <a href="/playground" class="btn btn-primary">Try Playground</a>
                        <a href="https://github.com/chemicallang/chemical" target="_blank" class="btn btn-secondary github-link">
                            <svg height="20" width="20" viewBox="0 0 16 16" version="1.1" aria-hidden="true"><path fill="currentColor" fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path></svg>
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
                    <h2 class="section-title">Why <span>Chemical</span>?</h2>
                    <div class="features-grid">
                        <div class="feature-card fade-in delay-100">
                            <h3>Native & Fast</h3>
                            <p>Compiles to C and runs via TinyCC or LLVM. Predictable performance with zero garbage collection overhead.</p>
                        </div>
                        <div class="feature-card fade-in delay-200">
                            <h3>Macro Power</h3>
                            <p>Built-in support for HTML and CSS macros, parsed by compiler plugins for safe and expressive web development.</p>
                        </div>
                        <div class="feature-card fade-in delay-300">
                            <h3>Modern Design</h3>
                            <p>Engineered for the 21st century, combining systems-level control with developer experience found in high-level languages.</p>
                        </div>
                    </div>
                </section>

                <section id="explore">
                    <h2 class="section-title">Explore the <span>Ecosystem</span></h2>
                    <div class="nav-grid">
                        <a href="https://docs.chemicallang.com" class="nav-card scroll-reveal">
                            <div class="nav-card-icon">📖</div>
                            <h3>Documentation</h3>
                            <p>Detailed guides and tutorials to master Chemical syntax, memory safety, and web macros.</p>
                        </a>

                        <a href="https://api.chemicallang.com" class="nav-card scroll-reveal">
                            <div class="nav-card-icon">📚</div>
                            <h3>API Reference</h3>
                            <p>Reference documentation for the Chemical standard library and core language modules.</p>
                        </a>

                        <a href="/playground" class="nav-card scroll-reveal">
                            <div class="nav-card-icon">🎮</div>
                            <h3>Playground</h3>
                            <p>Experiment with Chemical in our interactive editor. Write, compile, and run code instantly.</p>
                            <span class="nav-card-badge">Interactive</span>
                        </a>

                        <a href="https://chemicallang.github.io/components" class="nav-card scroll-reveal">
                            <div class="nav-card-icon">🧩</div>
                            <h3>Components</h3>
                            <p>See UI components built with HTML/CSS macros. Reactive interfaces in a systems language.</p>
                            <span class="nav-card-badge">Demo</span>
                        </a>
                    </div>
                </section>

                <section id="download">
                    <h2 class="section-title">Get <span>Chemical</span></h2>
                    <div class="download-grid">
                        <div class="os-card">
                            <h3>Windows</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/windows-x64.zip" class="download-link">
                                    <span class="arch">x64 (LLVM)</span>
                                    <span class="desc">Default Backend</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/windows-x64-tcc.zip" class="download-link">
                                    <span class="arch">x64 (TinyCC)</span>
                                    <span class="desc">Fast Compilation</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/windows-arm64.zip" class="download-link">
                                    <span class="arch">ARM64 (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/windows-arm64-tcc.zip" class="download-link">
                                    <span class="arch">ARM64 (TinyCC)</span>
                                </a>
                            </div>
                        </div>
                        <div class="os-card">
                            <h3>Linux</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/linux-x64.zip" class="download-link">
                                    <span class="arch">x64 (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/linux-x64-tcc.zip" class="download-link">
                                    <span class="arch">x64 (TinyCC)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/linux-arm64.zip" class="download-link">
                                    <span class="arch">ARM64 (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/linux-arm64-tcc.zip" class="download-link">
                                    <span class="arch">ARM64 (TinyCC)</span>
                                </a>
                            </div>
                        </div>
                        <div class="os-card">
                            <h3>macOS</h3>
                            <div class="download-links">
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/macos-x64.zip" class="download-link">
                                    <span class="arch">Intel (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/macos-x64-tcc.zip" class="download-link">
                                    <span class="arch">Intel (TinyCC)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/macos-arm64.zip" class="download-link">
                                    <span class="arch">Apple Silicon (LLVM)</span>
                                </a>
                                <a href="https://github.com/chemicallang/chemical/releases/download/v0.0.32/macos-arm64-tcc.zip" class="download-link">
                                    <span class="arch">Apple Silicon (TinyCC)</span>
                                </a>
                            </div>
                        </div>
                    </div>
                    <p class="note">Chemical is in <strong>Pre-Alpha</strong>. More releases available on <a href="https://github.com/chemicallang/chemical/releases" target="_blank" style="text-decoration:underline;">GitHub Releases</a>.</p>
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
                const particleCount = 70;
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
                        this.vx = (Math.random() - 0.5) * 0.4;
                        this.vy = (Math.random() - 0.5) * 0.4;
                        this.radius = Math.random() * 2 + 0.5;
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
                        ctx.fillStyle = isLight ? 'rgba(37, 99, 235, 0.15)' : 'rgba(56, 189, 248, 0.25)';
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
                                const opacity = 0.12 * (1 - dist / maxDistance);
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
