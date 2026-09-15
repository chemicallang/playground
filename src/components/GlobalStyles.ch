func GlobalStyles(page : &mut HtmlPage) {
    #html {
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta name="theme-color" content="#0A0A0C">
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
        </head>
        <style>{"""
            /* ============================================================
               CHEMICAL - DESIGN SYSTEM
               Aesthetic: precision instrument. Near-black ink, warm
               paper light mode, a single signal color, sharp 1px lines.
               ============================================================ */

            :root {
              --bg: #0A0A0C;
              --bg-elevated: #101014;
              --bg-inset: #060608;
              --text: #E8E8EC;
              --text-secondary: #9B9BA6;
              --text-dim: #63636E;
              --line: #1D1D23;
              --line-strong: #2A2A32;

              --accent: #4DA3FF;            /* signal blue */
              --accent-ink: #0A0A0C;        /* text on accent */
              --accent-dim: rgba(77, 163, 255, 0.14);
              --ok: #7EE0A3;
              --warn: #F0B45C;
              --err: #F0705C;

              --font-sans: 'Sora', system-ui, -apple-system, 'Segoe UI', sans-serif;
              --font-mono: 'IBM Plex Mono', ui-monospace, 'SF Mono', Menlo, monospace;

              --radius: 10px;
              --radius-sm: 6px;
              --ease: cubic-bezier(0.22, 1, 0.36, 1);
              --max-width: 1120px;
            }

            body.light-theme {
              --bg: #FAFAF7;                /* warm paper */
              --bg-elevated: #FFFFFF;
              --bg-inset: #F1F1EC;
              --text: #17171C;
              --text-secondary: #57575F;
              --text-dim: #8A8A93;
              --line: #E4E4DD;
              --line-strong: #D4D4CB;

              --accent: #1D5FBF;            /* deep blue, legible on paper */
              --accent-ink: #FAFAF7;
              --accent-dim: rgba(29, 95, 191, 0.10);
            }

            /* --- RESET & BASE --- */
            *, *::before, *::after { box-sizing: border-box; }
            html { scroll-behavior: smooth; }
            html, body { margin: 0; padding: 0; }
            body {
              font-family: var(--font-sans);
              background: var(--bg);
              color: var(--text);
              line-height: 1.6;
              font-size: 16px;
              -webkit-font-smoothing: antialiased;
              text-rendering: optimizeLegibility;
              -webkit-text-size-adjust: 100%;
              text-size-adjust: 100%;
              transition: background-color 0.35s var(--ease), color 0.35s var(--ease);
              overflow-x: hidden;
            }
            a { text-decoration: none; color: inherit; }
            img { max-width: 100%; display: block; }
            button { font-family: inherit; }
            ::selection { background: var(--accent); color: var(--accent-ink); }

            /* keyboard navigation: visible focus ring, mouse clicks unaffected */
            :focus { outline: none; }
            :focus-visible {
              outline: 2px solid var(--accent);
              outline-offset: 2px;
              border-radius: 4px;
            }

            .container { width: 100%; max-width: var(--max-width); margin: 0 auto; padding: 0 32px; }

            /* --- TYPE --- */
            h1, h2, h3 { letter-spacing: -0.02em; line-height: 1.15; margin: 0; }
            .kicker {
              font-family: var(--font-mono);
              font-size: 0.75rem;
              font-weight: 500;
              letter-spacing: 0.14em;
              text-transform: uppercase;
              color: var(--text-dim);
              display: flex;
              align-items: center;
              gap: 10px;
            }
            .kicker::before {
              content: '';
              width: 22px; height: 1px;
              background: var(--accent);
            }

            /* --- HEADER --- */
            header {
              position: sticky; top: 0; z-index: 1000;
              background: rgba(10, 10, 12, 0.82);
              backdrop-filter: blur(14px);
              -webkit-backdrop-filter: blur(14px);
              border-bottom: 1px solid var(--line);
            }
            body.light-theme header { background: rgba(250, 250, 247, 0.85); }

            .nav {
              display: flex; align-items: center; justify-content: space-between;
              height: 64px;
            }
            .logo {
              display: flex; align-items: center; gap: 10px;
              font-weight: 700; font-size: 1.05rem; letter-spacing: -0.01em;
              color: var(--text);
            }
            .logo img { height: 26px; width: auto; }
            .logo:hover { opacity: 0.85; }

            .nav-links { display: flex; align-items: center; gap: 4px; }
            .nav-link {
              padding: 8px 14px;
              font-size: 0.9rem; font-weight: 500;
              color: var(--text-secondary);
              border-radius: var(--radius-sm);
              transition: color 0.2s, background-color 0.2s;
            }
            .nav-link:hover { color: var(--text); background: var(--bg-elevated); }

            .theme-toggle {
              background: none; border: 1px solid transparent;
              cursor: pointer; color: var(--text-secondary);
              width: 36px; height: 36px;
              display: flex; align-items: center; justify-content: center;
              border-radius: var(--radius-sm);
              transition: color 0.2s, background-color 0.2s, border-color 0.2s;
            }
            .theme-toggle:hover { color: var(--text); background: var(--bg-elevated); border-color: var(--line); }

            /* --- BUTTONS --- */
            .btn {
              display: inline-flex; align-items: center; justify-content: center; gap: 8px;
              padding: 0 20px; height: 42px;
              font-size: 0.9rem; font-weight: 600;
              border-radius: var(--radius-sm);
              cursor: pointer; border: 1px solid transparent;
              transition: all 0.2s var(--ease);
              white-space: nowrap;
            }
            .btn-primary { background: var(--accent); color: var(--accent-ink); }
            .btn-primary:hover { filter: brightness(1.06); transform: translateY(-1px); }
            .btn-primary:active { transform: translateY(0); }
            .btn-ghost {
              background: transparent; color: var(--text);
              border-color: var(--line-strong);
            }
            .btn-ghost:hover { border-color: var(--text-dim); background: var(--bg-elevated); }
            .btn-sm { height: 34px; padding: 0 14px; font-size: 0.82rem; }
            .btn-nav { height: 36px; padding: 0 16px; font-size: 0.85rem; }

            /* --- SECTIONS --- */
            section { padding: 96px 0; }
            .section-head { margin-bottom: 56px; }
            .section-head .kicker { margin-bottom: 18px; }
            .section-title {
              font-size: clamp(1.9rem, 4vw, 2.6rem);
              font-weight: 700;
              max-width: 640px;
            }
            .section-sub {
              color: var(--text-secondary);
              max-width: 560px;
              margin-top: 14px;
              font-size: 1.02rem;
            }

            /* --- CARDS (flat, hairline) --- */
            .card {
              background: var(--bg-elevated);
              border: 1px solid var(--line);
              border-radius: var(--radius);
              transition: border-color 0.25s var(--ease), transform 0.25s var(--ease);
            }
            .card:hover { border-color: var(--line-strong); }

            /* --- FOOTER --- */
            footer {
              border-top: 1px solid var(--line);
              padding: 56px 0 40px;
              margin-top: 40px;
              background: var(--bg);
            }
            .footer-grid {
              display: grid;
              grid-template-columns: 1.5fr 1fr 1fr 1fr;
              gap: 48px;
            }
            .footer-brand p {
              color: var(--text-secondary);
              font-size: 0.92rem;
              max-width: 280px;
              margin: 14px 0 0;
              line-height: 1.65;
            }
            .footer-col h4 {
              font-family: var(--font-mono);
              font-size: 0.72rem; font-weight: 600;
              letter-spacing: 0.12em; text-transform: uppercase;
              color: var(--text-dim);
              margin: 0 0 16px;
            }
            .footer-col a {
              display: block;
              color: var(--text-secondary);
              font-size: 0.9rem;
              padding: 5px 0;
              transition: color 0.2s;
            }
            .footer-col a:hover { color: var(--accent); }
            .footer-bottom {
              display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;
              margin-top: 48px; padding-top: 24px;
              border-top: 1px solid var(--line);
              color: var(--text-dim);
              font-size: 0.84rem;
            }
            .footer-bottom .mono { font-family: var(--font-mono); font-size: 0.78rem; }

            /* --- REVEAL ANIMATION --- */
            @keyframes rise {
              from { opacity: 0; transform: translateY(14px); }
              to { opacity: 1; transform: translateY(0); }
            }
            .rise { animation: rise 0.7s var(--ease) both; }
            .rise-1 { animation-delay: 0.05s; } .rise-2 { animation-delay: 0.12s; }
            .rise-3 { animation-delay: 0.19s; } .rise-4 { animation-delay: 0.26s; }

            /* --- SCROLLBAR --- */
            ::-webkit-scrollbar { width: 10px; height: 10px; }
            ::-webkit-scrollbar-track { background: var(--bg); }
            ::-webkit-scrollbar-thumb { background: var(--line-strong); border-radius: 6px; border: 2px solid var(--bg); }
            ::-webkit-scrollbar-thumb:hover { background: var(--text-dim); }

            /* --- RESPONSIVE --- */
            @media (max-width: 900px) {
              .container { padding: 0 20px; }
              section { padding: 64px 0; }
              .footer-grid { grid-template-columns: 1fr 1fr; gap: 32px; }
            }
            @media (max-width: 640px) {
              .nav-links .nav-link { display: none; }
              .footer-grid { grid-template-columns: 1fr; }
              .btn { height: 44px; }   /* comfortable touch targets */
              .nav { height: 58px; }
            }

            /* respect users who prefer less motion */
            @media (prefers-reduced-motion: reduce) {
              *, *::before, *::after {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
                scroll-behavior: auto !important;
              }
            }
        """}</style>
    }
}
