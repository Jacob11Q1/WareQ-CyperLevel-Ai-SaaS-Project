/* ================= WAREQ GODMODE JS v2 ================= */
/* Fixes: smart preloader, optimized particles, throttled scroll, ARIA-friendly typewriter */

/* ================= PRELOADER ================= */
window.addEventListener("load", () => {
    const preloader = document.getElementById("preloader");
    if (preloader) {
        preloader.style.opacity = "0";
        setTimeout(() => (preloader.style.display = "none"), 600);
    }
});

/* ================= NAVBAR SHRINK ================= */
const navbar = document.querySelector(".cyber-nav");
window.addEventListener("scroll", () => {
    if (window.scrollY > 50) navbar.classList.add("scrolled");
    else navbar.classList.remove("scrolled");
});

/* ================= SCROLL PROGRESS ================= */
const scrollBar = document.getElementById("scrollBar");
let ticking = false;
window.addEventListener("scroll", () => {
    if (!ticking) {
        window.requestAnimationFrame(() => {
            const docHeight = document.body.scrollHeight - window.innerHeight;
            const scrollPercent = (window.scrollY / docHeight) * 100;
            if (scrollBar) scrollBar.style.width = scrollPercent + "%";
            ticking = false;
        });
        ticking = true;
    }
});

/* ================= BACK TO TOP ================= */
const backToTop = document.getElementById("backToTop");
window.addEventListener("scroll", () => {
    if (window.scrollY > 400) backToTop.style.display = "block";
    else backToTop.style.display = "none";
});
if (backToTop) backToTop.addEventListener("click", () => {
    window.scrollTo({ top: 0, behavior: "smooth" });
});

/* ================= TYPEWRITER ================= */
const heroHeading = document.querySelector(".hero-section h1");
const heroText = "Welcome to WareQ — The Cyber SaaS Experience";
if (heroHeading) {
    let i = 0;
    const typeWriter = () => {
        if (i < heroText.length) {
            heroHeading.innerHTML = heroText.substring(0, i + 1) + "<span aria-hidden='true' class='cursor'>|</span>";
            i++;
            setTimeout(typeWriter, 80);
        } else heroHeading.innerText = heroText;
    };
    typeWriter();
}

/* ================= GLITCH EFFECT ================= */
function glitchEffect(el) {
    const text = el.innerText;
    setInterval(() => {
        if (document.hidden) return;
        const glitchText = text.split("").map((c) => (Math.random() > 0.9 ? "█" : c)).join("");
        el.innerText = glitchText;
        setTimeout(() => (el.innerText = text), 200);
    }, 5000);
}
if (heroHeading) glitchEffect(heroHeading);

/* ================= COUNTER ================= */
const counters = document.querySelectorAll(".counter");
counters.forEach((counter) => {
    const update = () => {
        const target = +counter.getAttribute("data-target");
        const current = +counter.innerText.replace(/\D/g, "") || 0;
        const inc = Math.max(1, Math.ceil(target / 200));
        if (current < target) {
            counter.innerText = current + inc + "+";
            setTimeout(update, 20);
        } else counter.innerText = target + "+";
    };
    update();
});

/* ================= CARD HOVER TILT ================= */
const cards = document.querySelectorAll(".feature-card, .pricing-card");
cards.forEach((card) => {
    card.addEventListener("mousemove", (e) => {
        const { width, height, left, top } = card.getBoundingClientRect();
        const x = ((e.clientX - left) / width - 0.5) * 20;
        const y = ((e.clientY - top) / height - 0.5) * 20;
        card.style.transform = `rotateX(${y}deg) rotateY(${x}deg)`;
    });
    card.addEventListener("mouseleave", () => {
        card.style.transform = "rotateX(0deg) rotateY(0deg)";
    });
});

/* ================= PARTICLES ================= */
const canvas = document.createElement("canvas");
canvas.id = "cyberCanvas";
document.body.appendChild(canvas);
const ctx = canvas.getContext("2d");
canvas.style.cssText = "position:fixed;top:0;left:0;z-index:-5";
function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}
window.addEventListener("resize", resizeCanvas);
resizeCanvas();

let particles = [];
const count = window.innerWidth < 768 ? 50 : 120;
for (let i = 0; i < count; i++) {
    particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        r: Math.random() * 2 + 1,
        dx: (Math.random() - 0.5) * 1,
        dy: (Math.random() - 0.5) * 1,
        c: "rgba(56,189,248,0.7)",
    });
}
function drawParticles() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    for (let p of particles) {
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = p.c;
        ctx.fill();
        p.x += p.dx; p.y += p.dy;
        if (p.x < 0 || p.x > canvas.width) p.dx *= -1;
        if (p.y < 0 || p.y > canvas.height) p.dy *= -1;
    }
    requestAnimationFrame(drawParticles);
}
drawParticles();

/* ================= REVEAL ================= */
const revealEls = document.querySelectorAll(".feature-card, .pricing-card, .about img, .testimonial, .faq");
function revealOnScroll() {
    const h = window.innerHeight;
    revealEls.forEach((el) => {
        if (el.getBoundingClientRect().top < h - 100) el.classList.add("revealed");
    });
}
window.addEventListener("scroll", revealOnScroll);
revealOnScroll();

/* ================= CTA PULSE ================= */
const ctaButton = document.querySelector(".cta .btn-cyber");
if (ctaButton) setInterval(() => ctaButton.classList.toggle("pulse"), 2000);

/* ================= SHORTCUTS ================= */
document.addEventListener("keydown", (e) => {
    if (e.key === "s") {
        const modal = document.getElementById("subscribeModal");
        if (modal) new bootstrap.Modal(modal).show();
    }
});

/* ================= LOG ================= */
console.log("%cWareQ GODMODE v2 Ready ⚡", "color: cyan; font-size: 18px; font-weight: bold;");
