import "@html/page.ch"

func GlobalStyles(page : &mut HtmlPage) {
    #html {
        <style>{"""
            /* --- THEME VARIABLES (Modern Slate & Light/Dark) --- */
            :root {
              /* Default to Dark Mode (Slate) */
              --bg: #0f172a;             /* Slate 900 */
              --surface: #1e293b;        /* Slate 800 */
              --muted-surface: #334155;  /* Slate 700 */
              --text: #f8fafc;           /* Slate 50 */
              --text-muted: #94a3b8;     /* Slate 400 */
              --border-color: #334155;   /* Slate 700 */

              /* Accent - Tech Blue */
              --accent-primary: #3b82f6;    /* Blue 500 */
              --accent-primary-hover: #2563eb; /* Blue 600 */
              --accent-contrast: #ffffff;
              --accent-secondary: #64748b;  /* Slate 500 */

              /* UI tokens */
              --border-radius: 6px;      /* Slightly softer than industrial */
              --transition: 0.2s ease;
              --max-width: 1280px;
              --shadow-light: 0 1px 3px rgba(0, 0, 0, 0.3);
              --shadow-strong: 0 10px 15px -3px rgba(0, 0, 0, 0.4);
            }

            @media (prefers-color-scheme: light) {
              :root {
                --bg: #ffffff;             /* White */
                --surface: #f8fafc;        /* Slate 50 */
                --muted-surface: #e2e8f0;  /* Slate 200 */
                --text: #0f172a;           /* Slate 900 */
                --text-muted: #64748b;     /* Slate 500 */
                --border-color: #cbd5e1;   /* Slate 300 */

                --accent-primary: #2563eb;    /* Blue 600 */
                --accent-primary-hover: #1d4ed8; /* Blue 700 */
                --accent-contrast: #ffffff;
                
                --shadow-light: 0 1px 3px rgba(0, 0, 0, 0.1);
                --shadow-strong: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
              }
            }

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
              background: var(--bg); /* Use solid bg to prevent transparency issues in light mode */
              border-bottom: 1px solid var(--border-color);
              z-index: 100;
              transition: background-color 0.3s, border-color 0.3s;
            }
            .nav {
              display: flex; justify-content: space-between; align-items: center;
              padding: 1rem 0;
            }
            .logo {
              font-weight: 700; font-size: 1.5rem;
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

            /* --- BUTTONS --- */
            .btn {
              display: inline-flex; align-items: center; justify-content: center;
              padding: 0.6rem 1.2rem;
              font-weight: 600;
              font-size: 0.9rem;
              border-radius: var(--border-radius);
              cursor: pointer;
              transition: all var(--transition);
              border: 1px solid transparent;
            }
            .btn-primary {
              background: var(--accent-primary);
              color: var(--accent-contrast);
              border-color: var(--accent-primary);
              box-shadow: 0 1px 2px rgba(0,0,0,0.1);
            }
            .btn-primary:hover {
              background: var(--accent-primary-hover);
              border-color: var(--accent-primary-hover);
              transform: translateY(-1px);
              box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
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
            }

            /* --- HERO --- */
            .hero {
              display: grid;
              place-items: center;
              text-align: center;
              min-height: 60vh;
              position: relative;
              padding-top: 4rem;
            }
            
            .hero-content {
              position: relative; z-index: 1;
              max-width: 800px;
            }
            .hero h1 {
              font-size: 4rem;
              margin-bottom: 1.5rem;
              color: var(--text);
              letter-spacing: -0.03em;
              line-height: 1.1;
            }
            .hero p {
              color: var(--text-muted);
              font-size: 1.25rem;
              max-width: 600px;
              margin: 0 auto;
              font-weight: 400;
            }
            .hero .buttons { margin-top: 2.5rem; display: flex; gap: 1rem; justify-content: center; }

            /* --- SECTION TITLES --- */
            .section-title {
              font-size: 2rem;
              text-align: center;
              margin-bottom: 2rem;
              color: var(--text);
              letter-spacing: -0.02em;
            }
            section { padding: 4rem 0; }

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
              padding: 2rem;
              border-radius: var(--border-radius);
              border: 1px solid var(--border-color);
              transition: transform var(--transition);
            }
            .feature-card:hover {
              transform: translateY(-4px);
              border-color: var(--accent-primary);
            }
            .feature-card h3 {
              color: var(--text);
              margin-bottom: 1rem;
              font-size: 1.25rem;
            }
            .feature-card p {
              color: var(--text-muted);
              font-size: 0.95rem;
            }

            /* --- DOWNLOADS SECTION --- */
            .download-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
              gap: 1.5rem;
              margin-top: 2rem;
            }
            .os-card {
              background: var(--surface);
              padding: 1.5rem;
              border-radius: var(--border-radius);
              border: 1px solid var(--border-color);
              text-align: center;
            }
            .os-card h3 {
              margin-bottom: 1rem;
              color: var(--text);
            }
            .download-links {
              display: flex;
              flex-direction: column;
              gap: 0.75rem;
            }
            .download-link {
              display: block;
              padding: 0.75rem;
              background: var(--bg);
              border: 1px solid var(--border-color);
              border-radius: var(--border-radius);
              color: var(--text-muted);
              font-size: 0.9rem;
              transition: all var(--transition);
            }
            .download-link:hover {
              border-color: var(--accent-primary);
              color: var(--accent-primary);
              background: var(--muted-surface);
            }
            .download-link span {
              display: block;
              font-size: 0.75rem;
              opacity: 0.7;
              margin-top: 2px;
            }
            .note {
                text-align: center;
                margin-top: 2rem;
                color: var(--text-muted);
                font-size: 0.9rem;
            }

            /* --- GITHUB LINK --- */
            .github-link {
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                color: var(--text-muted);
                font-weight: 500;
                transition: color var(--transition);
            }
            .github-link:hover { color: var(--text); }

            /* --- FOOTER --- */
            footer {
              text-align: center;
              color: var(--text-muted);
              padding: 3rem 0;
              border-top: 1px solid var(--border-color);
              font-size: 0.9rem;
              margin-top: 4rem;
            }

            /* --- RESPONSIVE --- */
            @media (max-width: 768px) {
              .hero h1 { font-size: 2.5rem; }
              .nav { flex-direction: column; gap: 1rem; }
            }
        """}</style>
    }
}