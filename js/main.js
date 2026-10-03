const io = new IntersectionObserver(es =>
  es.forEach(e => { if (e.isIntersecting) { e.target.classList.add("in"); io.unobserve(e.target); } }));
document.querySelectorAll(".reveal").forEach(el => io.observe(el));

const root = document.documentElement, dark = matchMedia("(prefers-color-scheme: dark)");
document.getElementById("theme").onclick = () => {
  const isDark = root.dataset.theme === "dark" || (!root.dataset.theme && dark.matches);
  root.dataset.theme = localStorage.theme = isDark ? "light" : "dark";
};
