/**
 * CREAMU-Inspired Photography Site
 * Scattered Gallery with Scroll-Driven Animations
 */

/* ============================================
   SCROLL-DRIVEN GALLERY CONTROLLER
   ============================================ */

class ScatteredGallery {
    constructor() {
        this.items = document.querySelectorAll('.scattered-item');
        this.init();
    }

    init() {
        // Initial observation setup
        this.observeItems();

        // Scroll listener for smooth animations
        window.addEventListener('scroll', () => this.handleScroll(), { passive: true });

        // Initial check
        this.handleScroll();
    }

    observeItems() {
        const observer = new IntersectionObserver(
            (entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('visible');
                    }
                });
            },
            {
                threshold: 0.1,
                rootMargin: '50px'
            }
        );

        this.items.forEach(item => observer.observe(item));
    }

    handleScroll() {
        const scrollY = window.scrollY;
        const windowHeight = window.innerHeight;

        this.items.forEach((item, index) => {
            const itemTop = item.offsetTop;
            const itemHeight = item.offsetHeight;

            // Calculate visibility
            const isInView = (scrollY + windowHeight) > itemTop &&
                scrollY < (itemTop + itemHeight);

            if (isInView) {
                const delay = parseInt(item.dataset.delay) || 0;
                setTimeout(() => {
                    item.classList.add('visible');
                }, delay);
            }
        });
    }
}

/* ============================================
   SOUND TOGGLE (VISUALIZER)
   ============================================ */

class SoundToggle {
    constructor() {
        this.button = document.getElementById('soundToggle');
        this.visualizer = this.button?.querySelector('.visualizer');
        this.isActive = false;

        if (this.button) {
            this.init();
        }
    }

    init() {
        this.button.addEventListener('click', () => this.toggle());
    }

    toggle() {
        this.isActive = !this.isActive;

        if (this.isActive) {
            this.visualizer.classList.add('active');
            // Here you would trigger actual audio playback
            // For demo purposes, we just animate the visualizer
        } else {
            this.visualizer.classList.remove('active');
        }
    }
}

/* ============================================
   PAGE NAVIGATION (Home ↔ About)
   ============================================ */

class PageNavigator {
    constructor() {
        this.homePage = document.getElementById('home-page');
        this.aboutPage = document.getElementById('about-page');
        this.init();
    }

    init() {
        // About link click
        const aboutLinks = document.querySelectorAll('a[href="#about"]');
        aboutLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                this.showAbout();
            });
        });

        // Handle browser back button
        window.addEventListener('popstate', (e) => {
            if (e.state && e.state.page === 'about') {
                this.showAbout(false);
            } else {
                this.showHome(false);
            }
        });

        // Check initial hash
        if (window.location.hash === '#about') {
            this.showAbout(false);
        }
    }

    showAbout(updateHistory = true) {
        this.homePage.style.display = 'none';
        this.aboutPage.style.display = 'block';
        window.scrollTo(0, 0);

        if (updateHistory) {
            history.pushState({ page: 'about' }, '', '#about');
        }
    }

    showHome(updateHistory = true) {
        this.homePage.style.display = 'block';
        this.aboutPage.style.display = 'none';
        window.scrollTo(0, 0);

        if (updateHistory) {
            history.pushState({ page: 'home' }, '', '/');
        }
    }
}

/* ============================================
   SMOOTH SCROLL FOR ANCHOR LINKS
   ============================================ */

function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]:not([href="#about"])').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const href = this.getAttribute('href');
            if (href === '#') return;

            e.preventDefault();
            const target = document.querySelector(href);

            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

/* ============================================
   HERO TITLE IMAGE ROTATION (OPTIONAL)
   ============================================ */

class HeroTextImageRotator {
    constructor() {
        this.heroTitle = document.getElementById('heroTitle');
        this.images = [
            'Image1.jpg',
            'Image2.jpg',
            'Image3.jpg',
            'Image18.jpg',
            'Image19.jpg'
        ];
        this.currentIndex = 0;

        if (this.heroTitle) {
            this.startRotation();
        }
    }

    startRotation() {
        setInterval(() => {
            this.currentIndex = (this.currentIndex + 1) % this.images.length;
            this.heroTitle.style.backgroundImage = `url('${this.images[this.currentIndex]}')`;
        }, 5000); // Change image every 5 seconds
    }
}

/* ============================================
   PRELOAD IMAGES FOR SMOOTH EXPERIENCE
   ============================================ */

function preloadImages() {
    const images = document.querySelectorAll('img');
    images.forEach(img => {
        const tempImg = new Image();
        tempImg.src = img.src;
    });
}

/* ============================================
   INITIALIZE ON DOM READY
   ============================================ */

document.addEventListener('DOMContentLoaded', () => {
    // Initialize all modules
    new ScatteredGallery();
    new SoundToggle();
    new PageNavigator();
    new HeroTextImageRotator();

    initSmoothScroll();
    preloadImages();

    // Add fade-in animation to body
    document.body.style.opacity = '0';
    setTimeout(() => {
        document.body.style.transition = 'opacity 0.8s ease';
        document.body.style.opacity = '1';
    }, 100);
});

/* ============================================
   PERFORMANCE OPTIMIZATION
   ============================================ */

// Debounce scroll events for better performance
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Optional: Add parallax effect to scattered items
function addParallaxEffect() {
    const items = document.querySelectorAll('.scattered-item.visible');

    window.addEventListener('scroll', debounce(() => {
        const scrollY = window.scrollY;

        items.forEach((item, index) => {
            const speed = 0.5 + (index % 3) * 0.1; // Varying speeds
            const yPos = -(scrollY * speed * 0.1);
            item.style.transform = `translateY(${yPos}px) scale(1)`;
        });
    }, 10), { passive: true });
}

// Uncomment to enable parallax:
// document.addEventListener('DOMContentLoaded', addParallaxEffect);
