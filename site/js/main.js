document.addEventListener('DOMContentLoaded', () => {

  // --- Theme Toggle ---
  const toggle = document.querySelector('.theme-toggle');
  const root = document.documentElement;

  function setTheme(theme) {
    root.setAttribute('data-theme', theme);
    localStorage.setItem('shiplog-theme', theme);
  }

  // Load saved preference, fall back to system preference
  const saved = localStorage.getItem('shiplog-theme');
  if (saved) {
    setTheme(saved);
  } else if (window.matchMedia('(prefers-color-scheme: light)').matches) {
    setTheme('light');
  }

  toggle.addEventListener('click', () => {
    const current = root.getAttribute('data-theme');
    setTheme(current === 'light' ? 'dark' : 'light');
  });

  // --- Scroll Progress Bar ---
  const progressBar = document.querySelector('.scroll-progress');
  window.addEventListener('scroll', () => {
    const scrollPercent = window.scrollY / (document.body.scrollHeight - window.innerHeight);
    progressBar.style.width = `${scrollPercent * 100}%`;
  }, { passive: true });

  // --- Scroll Reveal (IntersectionObserver) ---
  const revealElements = document.querySelectorAll('.reveal, .terminal-reveal, .reveal-stagger');

  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        revealObserver.unobserve(entry.target);

        // Trigger terminal line reveals
        if (entry.target.classList.contains('terminal-reveal')) {
          revealTerminalLines(entry.target);
        }

        // Trigger progress bar fills
        if (entry.target.querySelector('.progress-fill')) {
          animateProgressBars(entry.target);
        }
      }
    });
  }, {
    threshold: 0.15,
    rootMargin: '0px 0px -60px 0px'
  });

  revealElements.forEach(el => revealObserver.observe(el));

  // --- Typewriter Effect ---
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  const typewriterEls = document.querySelectorAll('.typewriter');
  const typewriterObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const el = entry.target;
        const text = el.dataset.text;

        if (reducedMotion) {
          el.textContent = text;
          el.style.visibility = 'visible';
        } else {
          typewriter(el, text, 50);
        }
        typewriterObserver.unobserve(el);
      }
    });
  }, { threshold: 0.5 });

  typewriterEls.forEach(el => typewriterObserver.observe(el));

  function typewriter(element, text, speed) {
    element.textContent = '';
    element.style.visibility = 'visible';
    let i = 0;
    function type() {
      if (i < text.length) {
        element.textContent += text.charAt(i);
        i++;
        setTimeout(type, speed);
      }
    }
    type();
  }

  // --- Terminal Line-by-Line Reveal ---
  function revealTerminalLines(terminal) {
    const lines = terminal.querySelectorAll('.term-line');
    lines.forEach((line, i) => {
      if (reducedMotion) return;
      line.style.opacity = '0';
      line.style.transform = 'translateX(-8px)';
      setTimeout(() => {
        line.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
        line.style.opacity = '1';
        line.style.transform = 'translateX(0)';
      }, 200 + i * 80);
    });
  }

  // --- Progress Bar Animation ---
  function animateProgressBars(container) {
    const fills = container.querySelectorAll('.progress-fill');
    fills.forEach((fill, i) => {
      const width = fill.dataset.width || 0;
      setTimeout(() => {
        fill.style.width = width + '%';
      }, 400 + i * 200);
    });
  }

  // --- Copy to Clipboard ---
  document.querySelectorAll('.copy-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const text = btn.dataset.copy;
      navigator.clipboard.writeText(text).then(() => {
        btn.textContent = 'Copied!';
        btn.classList.add('copied');
        setTimeout(() => {
          btn.textContent = 'Copy';
          btn.classList.remove('copied');
        }, 2000);
      });
    });
  });

});
