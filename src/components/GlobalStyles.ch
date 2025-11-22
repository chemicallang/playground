import "@html/page.ch"

func GlobalStyles(page : &mut HtmlPage) {
    #html {
        <style>{"""
            /* --- THEME VARIABLES (Premium Dark & Light) --- */
            :root {
              /* Default to Dark Mode (Deep Space) */
              --bg: #0B1120;             /* Deepest Navy/Black */
              --surface: #1E293B;        /* Slate 800 */
              --muted-surface: #334155;  /* Slate 700 */
              --text: #F8FAFC;           /* Slate 50 */
              --text-muted: #94A3B8;     /* Slate 400 */
              --border-color: #1E293B;   /* Slate 800 */

              /* Accent - Electric Blue */
              --accent-primary: #3B82F6;    /* Blue 500 */
              --accent-primary-hover: #60A5FA; /* Blue 400 (lighter for dark mode hover) */
              --accent-contrast: #FFFFFF;
              --accent-secondary: #64748B;  /* Slate 500 */
              
              /* Glows */
              --glow-color: rgba(59, 130, 246, 0.5);

              /* UI tokens */
              --border-radius: 8px;
              --transition: 0.2s cubic-bezier(0.4, 0, 0.2, 1);
              --max-width: 1280px;
              --shadow-light: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
              --shadow-strong: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            }

            /* Manual Light Mode Override */
            body.light-theme {
                --bg: #FFFFFF;             /* White */
                --surface: #F1F5F9;        /* Slate 100 */
                --muted-surface: #E2E8F0;  /* Slate 200 */
                --text: #0F172A;           /* Slate 900 */
                --text-muted: #475569;     /* Slate 600 */
                --border-color: #E2E8F0;   /* Slate 200 */

                --accent-primary: #2563EB;    /* Blue 600 */
                --accent-primary-hover: #1D4ED8; /* Blue 700 */
                --accent-contrast: #FFFFFF;
                
                --glow-color: rgba(37, 99, 235, 0.3);
                
                --shadow-light: 0 1px 3px rgba(0, 0, 0, 0.1);
                --shadow-strong: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
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
            * { box-sizing: border-box; margin: 0; padding: 0; }
            body {
              font-family: 'Inter', system-ui, -apple-system, sans-serif;
              background: var(--bg);
              color: var(--text);
              line-height: 1.6;
              -webkit-font-smoothing: antialiased;
              transition: background-color 0.3s, color 0.3s;
            }
            a { text-decoration: none; }
            img { max-width: 100%; display: block; }
            .container { width: 90%; max-width: var(--max-width); margin: 0 auto; }

            /* --- HEADER & NAV --- */
            header {
              position: sticky; top: 0;
              background: rgba(11, 17, 32, 0.8); /* Translucent dark */
              backdrop-filter: blur(12px);
              -webkit-backdrop-filter: blur(12px);
              border-bottom: 1px solid var(--border-color);
              z-index: 100;
              transition: background-color 0.3s, border-color 0.3s;
            }
            body.light-theme header {
                background: rgba(255, 255, 255, 0.8);
            }

            .nav {
              display: flex; justify-content: space-between; align-items: center;
              padding: 1rem 0;
            }
            .logo {
              font-weight: 800; font-size: 1.5rem;
              color: var(--text);
              display: flex; align-items: center;
              gap: 0.75rem;
              letter-spacing: -0.02em;
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
                background-color: var(--surface);
            }

            /* --- BUTTONS --- */
            .btn {
              display: inline-flex; align-items: center; justify-content: center;
              padding: 0.6rem 1.4rem;
              font-weight: 600;
              font-size: 0.95rem;
              border-radius: var(--border-radius);
              cursor: pointer;
              transition: all var(--transition);
              border: 1px solid transparent;
            }
            .btn-primary {
              background: var(--accent-primary);
              color: var(--accent-contrast);
              border-color: var(--accent-primary);
              box-shadow: 0 0 15px var(--glow-color);
            }
            .btn-primary:hover {
              background: var(--accent-primary-hover);
              border-color: var(--accent-primary-hover);
              transform: translateY(-2px);
              box-shadow: 0 0 25px var(--glow-color);
            }
            .btn-secondary {
              background: var(--surface);
              color: var(--text);
              border: 1px solid var(--border-color);
            }
            .btn-secondary:hover {
              background: var(--muted-surface);
              border-color: var(--text-muted);
              color: var(--text);
              transform: translateY(-2px);
            }

            /* --- HERO --- */
            .hero {
              display: grid;
              place-items: center;
              text-align: center;
              min-height: 70vh;
              position: relative;
              padding-top: 4rem;
              overflow: hidden;
            }
            
            /* Background Glow Effect */
            .hero::before {
                content: '';
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                width: 600px;
                height: 600px;
                background: radial-gradient(circle, var(--glow-color) 0%, transparent 70%);
                opacity: 0.15;
                z-index: 0;
                pointer-events: none;
            }

            .hero-content {
              position: relative; z-index: 1;
              max-width: 800px;
            }
            .hero h1 {
              font-size: 4.5rem;
              margin-bottom: 1.5rem;
              color: var(--text);
              letter-spacing: -0.04em;
              line-height: 1.1;
              background: linear-gradient(to right, var(--text) 20%, var(--accent-primary) 100%);
              -webkit-background-clip: text;
              -webkit-text-fill-color: transparent;
            }
            .hero p {
              color: var(--text-muted);
              font-size: 1.35rem;
              max-width: 650px;
              margin: 0 auto;
              font-weight: 400;
              line-height: 1.6;
            }
            .hero .buttons { margin-top: 3rem; display: flex; gap: 1rem; justify-content: center; }

            /* --- SECTION TITLES --- */
            .section-title {
              font-size: 2.5rem;
              text-align: center;
              margin-bottom: 3rem;
              color: var(--text);
              letter-spacing: -0.03em;
              font-weight: 800;
            }
            section { padding: 6rem 0; }

            /* --- COMMUNITY --- */
            .community p {
                text-align : center;
                color: var(--text-muted);
            }
            .community-links {
              display: flex; gap: 1rem; justify-content: center; margin-top: 1.5rem;
            }
            .community-links a { font-weight: 600; color: var(--text); text-decoration: underline; text-decoration-color: var(--border-color); text-underline-offset: 4px; }
            .community-links a:hover { text-decoration-color: var(--accent-primary); }

            /* --- FEATURES SECTION --- */
            .features-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
              gap: 2rem;
              margin-top: 2rem;
            }
            .feature-card {
              background: var(--surface);
              padding: 2.5rem;
              border-radius: var(--border-radius);
              border: 1px solid var(--border-color);
              transition: all var(--transition);
              position: relative;
              overflow: hidden;
            }
            .feature-card:hover {
              transform: translateY(-8px);
              border-color: var(--accent-primary);
              box-shadow: var(--shadow-strong);
            }
            .feature-card h3 {
              color: var(--text);
              margin-bottom: 1rem;
              font-size: 1.5rem;
              font-weight: 700;
            }
            .feature-card p {
              color: var(--text-muted);
              font-size: 1rem;
              line-height: 1.7;
            }

            /* --- DOWNLOADS SECTION --- */
            .download-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
              gap: 2rem;
              margin-top: 2rem;
            }
            .os-card {
              background: var(--surface);
              padding: 2rem;
              border-radius: var(--border-radius);
              border: 1px solid var(--border-color);
              text-align: center;
              transition: transform var(--transition);
            }
            .os-card:hover {
                transform: translateY(-4px);
                border-color: var(--text-muted);
            }
            .os-card h3 {
              margin-bottom: 1.5rem;
              color: var(--text);
              font-size: 1.25rem;
              font-weight: 700;
            }
            .download-links {
              display: flex;
              flex-direction: column;
              gap: 1rem;
            }
            .download-link {
              display: block;
              padding: 1rem;
              background: var(--bg);
              border: 1px solid var(--border-color);
              border-radius: var(--border-radius);
              color: var(--text-muted);
              font-size: 0.95rem;
              transition: all var(--transition);
              font-weight: 500;
            }
            .download-link:hover {
              border-color: var(--accent-primary);
              color: var(--accent-primary);
              background: var(--muted-surface);
              transform: scale(1.02);
            }
            .download-link span {
              display: block;
              font-size: 0.75rem;
              opacity: 0.7;
              margin-top: 4px;
            }
            .note {
                text-align: center;
                margin-top: 3rem;
                color: var(--text-muted);
                font-size: 0.95rem;
            }

            /* --- GITHUB LINK --- */
            .github-link {
                display: inline-flex;
                align-items: center;
                gap: 0.6rem;
                color: var(--text);
                font-weight: 600;
                transition: all var(--transition);
            }
            .github-link svg {
                fill: currentColor;
                transition: fill 0.2s;
            }
            .github-link:hover { 
                color: var(--text); 
                background: var(--muted-surface);
            }

            /* --- FOOTER --- */
            footer {
              text-align: center;
              color: var(--text-muted);
              padding: 4rem 0;
              border-top: 1px solid var(--border-color);
              font-size: 0.9rem;
              margin-top: 6rem;
              background: var(--bg);
            }

            /* --- RESPONSIVE --- */
            @media (max-width: 768px) {
              .hero h1 { font-size: 3rem; }
              .nav { flex-direction: column; gap: 1rem; }
              .hero { min-height: auto; padding-bottom: 4rem; }
            }
        """}</style>
    }
}