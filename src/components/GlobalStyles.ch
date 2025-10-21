import "@html/page.ch"

func GlobalStyles(page : &mut HtmlPage) {
    #html {
        <style>{"""
            /* --- THEME VARIABLES --- */
            :root {
              /* Base colors */
              --bg: #111827;             /* Dark slate background */
              --surface: #1f2937;        /* Slightly lighter surface */
              --muted-surface: #374151;  /* Muted card background */
              --text: #f9fafb;           /* Light text */
              --text-muted: #9ca3af;     /* Muted text */

              /* Accent palette */
              --accent-primary: #8b5cf6;    /* Violet */
              --accent-primary-hover: #7c3aed;
              --accent-secondary: #f472b6;  /* Pink */

              /* UI tokens */
              --border-radius: 0.75rem;
              --transition: 0.35s ease;
              --max-width: 1280px;
              --shadow-light: 0 2px 10px rgba(0, 0, 0, 0.25);
              --shadow-strong: 0 4px 20px rgba(0, 0, 0, 0.5);
            }

            /* --- RESET & BASE --- */
            * { box-sizing: border-box; margin: 0; padding: 0; }
            body {
              font-family: 'Inter', sans-serif;
              background: var(--bg);
              color: var(--text);
              line-height: 1.6;
            }
            a { text-decoration: none; }
            img { max-width: 100%; display: block; }
            .container { width: 90%; max-width: var(--max-width); margin: 0 auto; }

            /* --- HEADER & NAV --- */
            header {
              position: sticky; top: 0;
              background: rgba(31, 41, 55, 0.9);
              backdrop-filter: blur(8px);
              z-index: 100;
              box-shadow: var(--shadow-light);
            }
            .nav {
              display: flex; justify-content: space-between; align-items: center;
              padding: 1rem 0;
            }
            .logo {
              font-weight: 700; font-size: 1.5rem;
              color: var(--accent-primary);
              display: flex; align-items: center;
              gap: 0.5rem;
            }
            nav.nav-links {
              display: flex; align-items: center; gap: 1.5rem;
            }
            nav a {
              position: relative;
              color: var(--text);
              font-weight: 500;
              transition: color var(--transition);
            }
            nav a::after {
              content: '';
              position: absolute; bottom: -4px; left: 0;
              width: 0%; height: 2px;
              background: var(--accent-primary);
              transition: width var(--transition);
            }
            nav a:hover { color: var(--accent-primary); }
            nav a:hover::after { width: 100%; }

            /* --- BUTTONS & TOGGLE --- */
            .btn {
              display: inline-flex; align-items: center; justify-content: center;
              padding: 0.8rem 1.4rem;
              font-weight: 600;
              border-radius: var(--border-radius);
              cursor: pointer;
              transition: transform var(--transition), background var(--transition);
              box-shadow: var(--shadow-light);
              border: none;
            }
            .btn-primary { background: var(--accent-primary); color: #fff; }
            .btn-primary:hover {
              background: var(--accent-primary-hover);
              transform: translateY(-2px);
              box-shadow: var(--shadow-strong);
            }
            .btn-secondary {
              background: var(--accent-secondary); color: #fff;
            }
            .btn-secondary:hover {
              background: #ec4899;
              transform: translateY(-2px);
            }

            /* --- HERO --- */
            .hero {
              display: grid;
              place-items: center;
              text-align: center;
              min-height: 70vh;
              position: relative;
              overflow: hidden;
            }
            .hero::before {
              content: '';
              position: absolute; inset: 0;
              background: radial-gradient(circle at center, rgba(139,92,246,0.2), transparent 70%);
              z-index: 0;
            }
            .hero-content {
              position: relative; z-index: 1;
            }
            .hero h1 {
              font-size: 3.5rem; margin-bottom: 1rem;
              background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
              -webkit-background-clip: text;
              -webkit-text-fill-color: transparent;
            }
            .hero p {
              color: var(--text-muted);
              font-size: 1.25rem;
              max-width: 600px;
              margin: 0 auto;
            }
            .hero .buttons { margin-top: 2rem; display: flex; gap: 1rem; justify-content: center; }

            /* --- SECTION TITLES --- */
            .section-title {
              font-size: 2.25rem;
              text-align: center;
              margin-bottom: 2rem;
              color: var(--accent-primary);
            }
            section { padding: 4rem 0; }

            /* --- COMMUNITY --- */
            .community p {
                text-align : center;
            }
            .community-links {
              display: flex; gap: 1rem; justify-content: center; margin-top: 1.5rem;
            }
            .community-links a { font-weight: 600; }

            /* --- FOOTER --- */
            footer {
              text-align: center;
              color: var(--text-muted);
              padding: 2rem 0;
              border-top: 1px solid var(--muted-surface);
            }

            /* --- RESPONSIVE --- */
            @media (max-width: 768px) {
              .docs-container { flex-direction: column; }
              .sidebar { position: relative; top: auto; max-height: none; width: 100%; }
              nav.nav-links { flex-direction: column; gap: 0.75rem; }
              .hero h1 { font-size: 2.5rem; }
            }
        """}</style>
    }
}