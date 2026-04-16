func GlobalStyles(page : &mut HtmlPage) {
    #html {
        <head>
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
        </head>
        <style>{"""
            /* --- THEME VARIABLES (Premium Glassmorphic) --- */
            :root {
              /* Default to Dark Mode (Deep Space) */
              --bg: #020617;             /* Deepest Navy */
              --bg-alt: #0F172A;         /* Slate 900 */
              --surface: rgba(30, 41, 59, 0.4); /* Slate 800 with low opacity */
              --muted-surface: rgba(51, 65, 85, 0.4);
              --text: #F8FAFC;           /* Slate 50 */
              --text-muted: #94A3B8;     /* Slate 400 */
              --border-color: rgba(255, 255, 255, 0.1);
              
              /* Accent - Electric Blue / Cyan */
              --accent-primary: #38BDF8;    /* Sky 400 */
              --accent-primary-hover: #0EA5E9; /* Sky 500 */
              --accent-contrast: #FFFFFF;
              --accent-secondary: #818CF8;  /* Indigo 400 */
              
              /* Gradients */
              --gradient-primary: linear-gradient(135deg, #38BDF8 0%, #818CF8 100%);
              
              /* Glows */
              --glow-color: rgba(56, 189, 248, 0.2);

              /* UI tokens */
              --border-radius: 16px;
              --transition: 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
              --max-width: 1400px;
              --shadow-light: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
              --shadow-strong: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
              
              /* Glassmorphism */
              --glass-bg: rgba(255, 255, 255, 0.03);
              --glass-border: rgba(255, 255, 255, 0.08);
              --glass-blur: blur(12px);
              
              --font-sans: 'Outfit', system-ui, -apple-system, sans-serif;
              --font-mono: 'JetBrains Mono', monospace;
            }

            /* Manual Light Mode Override */
            body.light-theme {
                --bg: #F8FAFC;             /* Slate 50 */
                --bg-alt: #F1F5F9;         /* Slate 100 */
                --surface: rgba(241, 245, 249, 0.8);
                --muted-surface: rgba(226, 232, 240, 0.8);
                --text: #0F172A;           /* Slate 900 */
                --text-muted: #475569;     /* Slate 600 */
                --border-color: rgba(30, 41, 59, 0.1);

                --accent-primary: #0284C7;    /* Sky 600 */
                --accent-primary-hover: #0369A1; /* Sky 700 */
                --accent-contrast: #FFFFFF;
                
                --glow-color: rgba(2, 132, 199, 0.1);
                
                --glass-bg: rgba(255, 255, 255, 0.7);
                --glass-border: rgba(30, 41, 59, 0.1);
            }

            /* --- ANIMATIONS --- */
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(20px); }
                to { opacity: 1; transform: translateY(0); }
            }

            .fade-in {
                animation: fadeIn 0.8s ease-out forwards;
            }
            
            .delay-100 { animation-delay: 0.1s; }
            .delay-200 { animation-delay: 0.2s; }
            .delay-300 { animation-delay: 0.3s; }

            /* --- RESET & BASE --- */
            html, body { margin: 0; padding: 0; }
            * { box-sizing: border-box; }
            body {
              font-family: var(--font-sans);
              background: var(--bg);
              color: var(--text);
              line-height: 1.6;
              -webkit-font-smoothing: antialiased;
              transition: background-color 0.3s, color 0.3s;
              overflow-x: hidden;
            }
            a { text-decoration: none; color: inherit; }
            img { max-width: 100%; display: block; }
            .container { width: 90%; max-width: var(--max-width); margin: 0 auto; }

            /* --- HEADER & NAV --- */
            header {
              position: sticky; top: 0;
              background: var(--glass-bg);
              backdrop-filter: var(--glass-blur);
              -webkit-backdrop-filter: var(--glass-blur);
              border-bottom: 1px solid var(--glass-border);
              z-index: 1000;
              transition: all 0.3s ease;
            }

            .nav {
              display: flex; justify-content: space-between; align-items: center;
              padding: 1rem 0;
            }
            .logo {
              font-weight: 800; font-size: 1.75rem;
              color: var(--text);
              display: flex; align-items: center;
              gap: 0.75rem;
              letter-spacing: -0.02em;
              transition: transform 0.2s ease;
            }
            .logo:hover { transform: scale(1.02); }
            .logo span {
                background: var(--gradient-primary);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            nav.nav-links {
              display: flex; align-items: center; gap: 1.5rem;
            }
            nav a {
              position: relative;
              color: var(--text-muted);
              font-weight: 500;
              transition: color var(--transition);
              font-size: 0.95rem;
            }
            nav a:hover { color: var(--accent-primary); }

            /* Theme Toggle Button */
            .theme-toggle {
                background: none;
                border: none;
                cursor: pointer;
                color: var(--text-muted);
                padding: 0.5rem;
                border-radius: 50%;
                transition: color 0.2s, background-color 0.2s;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .theme-toggle:hover {
                color: var(--text);
                background-color: var(--glass-bg);
            }

            /* --- BUTTONS --- */
            .btn {
              display: inline-flex; align-items: center; justify-content: center;
              padding: 0.75rem 1.75rem;
              font-weight: 600;
              font-size: 1rem;
              border-radius: var(--border-radius);
              cursor: pointer;
              transition: all var(--transition);
              border: 1px solid transparent;
              gap: 0.5rem;
              font-family: var(--font-sans);
            }
            .btn:hover {
                transform: translateY(-2px);
            }
            .btn-primary {
              background: var(--gradient-primary);
              color: var(--accent-contrast);
              border: none;
              box-shadow: 0 4px 15px var(--glow-color);
            }
            .btn-primary:hover {
              filter: brightness(1.1);
              box-shadow: 0 8px 25px var(--glow-color);
            }
            .btn-secondary {
              background: var(--glass-bg);
              color: var(--text);
              border: 1px solid var(--glass-border);
              backdrop-filter: var(--glass-blur);
            }
            .btn-secondary:hover {
              background: var(--muted-surface);
              border-color: var(--accent-primary);
            }

            footer {
              text-align: center;
              color: var(--text-muted);
              padding: 4rem 0;
              border-top: 1px solid var(--border-color);
              font-size: 0.9rem;
              margin-top: 6rem;
              background: var(--bg);
            }

            /* --- SECTION TITLES --- */
            .section-title {
              font-size: clamp(2rem, 5vw, 3rem);
              text-align: center;
              margin-bottom: 3.5rem;
              color: var(--text);
              letter-spacing: -0.03em;
              font-weight: 800;
            }
            .section-title span {
                background: var(--gradient-primary);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            section { padding: 6rem 0; }

            /* --- FEATURE CARDS --- */
            .features-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
              gap: 2rem;
            }
            .feature-card {
              background: var(--glass-bg);
              padding: 3rem;
              border-radius: var(--border-radius);
              border: 1px solid var(--glass-border);
              backdrop-filter: var(--glass-blur);
              transition: all var(--transition);
              position: relative;
              overflow: hidden;
            }
            .feature-card:hover {
              transform: translateY(-8px);
              border-color: var(--accent-primary);
              box-shadow: var(--shadow-strong);
              background: rgba(255, 255, 255, 0.05);
            }
            .feature-card h3 {
              color: var(--text);
              margin-bottom: 1rem;
              font-size: 1.75rem;
              font-weight: 700;
              letter-spacing: -0.02em;
            }
            .feature-card p {
              color: var(--text-muted);
              font-size: 1.05rem;
              line-height: 1.7;
            }

            /* --- SCROLLBAR --- */
            ::-webkit-scrollbar {
                width: 10px;
            }
            ::-webkit-scrollbar-track {
                background: var(--bg);
            }
            ::-webkit-scrollbar-thumb {
                background: var(--bg-alt);
                border-radius: 10px;
                border: 2px solid var(--bg);
            }
            ::-webkit-scrollbar-thumb:hover {
                background: var(--text-muted);
            }

            /* --- RESPONSIVE --- */
            @media (max-width: 768px) {
              .nav { flex-direction: column; gap: 1rem; }
              section { padding: 4rem 0; }
            }
        """}</style>
    }
}