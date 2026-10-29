'use strict';

class Slider {
  constructor(root) {
    this.root = root;
    this.slides = [...root.querySelectorAll('.slide')];
    this.dots = [...root.querySelectorAll('[data-dot]')];
    this.index = 0;
    this.paused = matchMedia('(prefers-reduced-motion: reduce)').matches;
    this.pauseButton = root.querySelector('[data-pause]');
    this.pauseButton.addEventListener('click', () => {
      this.paused = !this.paused;
      this.schedule();
    });
    this.dots.forEach((dot, index) => dot.addEventListener('click', () => this.go(index)));
    root.querySelectorAll('[data-step]').forEach(button => {
      button.addEventListener('click', () => this.go(this.index + Number(button.dataset.step)));
    });
    this.schedule();
  }
  go(index) {
    this.index = (index + this.slides.length) % this.slides.length;
    this.slides.forEach((slide, position) => {
      const current = position === this.index;
      slide.classList.toggle('is-current', current);
      slide.setAttribute('aria-hidden', String(!current));
      this.dots[position].setAttribute('aria-pressed', String(current));
    });
    this.schedule();
  }
  schedule() {
    clearTimeout(this.timer);
    this.pauseButton.textContent = this.paused ? '▶' : 'Ⅱ';
    this.pauseButton.setAttribute('aria-label', this.paused ? 'Запустить слайды' : 'Приостановить слайды');
    if (!this.paused) this.timer = setTimeout(() => this.go(this.index + 1), 3000);
  }
}

document.querySelectorAll('[data-slider]').forEach(element => new Slider(element));
