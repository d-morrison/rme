// Equation zoom: makes Quarto figure divs containing display math clickable,
// opening them in a centered modal (similar to image lightbox).
// Requires MathJax (html-math-method: mathjax) — harmless no-op otherwise.
(function () {
  'use strict';

  function init() {
    // Find Quarto float/figure containers that hold display math equations
    document.querySelectorAll('.quarto-float').forEach(function (float) {
      if (!float.querySelector('mjx-container[display="true"]')) return;
      addZoom(float);
    });

    // Also handle display equations that live outside figure floats
    document.querySelectorAll('mjx-container[display="true"]').forEach(function (math) {
      if (math.closest('.quarto-float')) return; // already handled above
      addZoomToMath(math);
    });
  }

  function addZoom(float) {
    const body = float.querySelector('.quarto-float-body') || float.querySelector('figure') || float;
    body.classList.add('eq-zoom-trigger');
    body.setAttribute('tabindex', '0');
    body.setAttribute('title', 'Click to zoom');
    body.addEventListener('click', function () { openModal(float); });
    body.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); openModal(float); }
    });
  }

  function addZoomToMath(math) {
    // Wrap the bare display equation in a div so we have a stable click target
    const wrapper = document.createElement('div');
    wrapper.className = 'eq-zoom-trigger eq-zoom-standalone';
    wrapper.setAttribute('tabindex', '0');
    wrapper.setAttribute('title', 'Click to zoom');
    math.parentNode.insertBefore(wrapper, math);
    wrapper.appendChild(math);
    wrapper.addEventListener('click', function () { openModal(wrapper); });
    wrapper.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); openModal(wrapper); }
    });
  }

  function openModal(sourceEl) {
    var overlay = document.createElement('div');
    overlay.className = 'eq-zoom-overlay';
    overlay.setAttribute('role', 'dialog');
    overlay.setAttribute('aria-modal', 'true');
    overlay.setAttribute('aria-label', 'Zoomed equation');

    var dialog = document.createElement('div');
    dialog.className = 'eq-zoom-dialog';

    var closeBtn = document.createElement('button');
    closeBtn.className = 'eq-zoom-close';
    closeBtn.innerHTML = '&#x2715;';
    closeBtn.setAttribute('aria-label', 'Close');

    var clone = sourceEl.cloneNode(true);
    clone.removeAttribute('id');
    // Remove zoom trigger styles/attributes from clone
    var trigger = clone.querySelector('.eq-zoom-trigger') || clone;
    trigger.classList.remove('eq-zoom-trigger');
    trigger.removeAttribute('tabindex');
    trigger.removeAttribute('title');
    // Restore pointer cursor inside modal
    trigger.style.cursor = 'default';

    dialog.appendChild(closeBtn);
    dialog.appendChild(clone);
    overlay.appendChild(dialog);
    document.body.appendChild(overlay);

    function close() {
      overlay.remove();
      document.removeEventListener('keydown', keyHandler);
    }
    function keyHandler(e) { if (e.key === 'Escape') close(); }

    closeBtn.addEventListener('click', close);
    overlay.addEventListener('click', function (e) { if (e.target === overlay) close(); });
    document.addEventListener('keydown', keyHandler);
    closeBtn.focus();
  }

  // Run after MathJax finishes typesetting (it's async), or after page load if
  // MathJax is absent.
  if (window.MathJax && MathJax.startup) {
    MathJax.startup.promise.then(init).catch(init);
  } else {
    // MathJax not yet defined — wait for it, then hook its promise
    window.addEventListener('load', function () {
      if (window.MathJax && MathJax.startup) {
        MathJax.startup.promise.then(init).catch(init);
      } else {
        init();
      }
    });
  }
}());
