# Country Horizon RV Park Site Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current repo (an unused Express/Jade scaffold wrapping a generic 2014 agency template) with a fast, mobile-first, SEO-correct static site for Country Horizon RV Park, using only verified real facts and real assets.

**Architecture:** A single static HTML page (`index.html`) with anchor-linked sections, one stylesheet, one small JS file (nav toggle + dynamic year), real photos pulled from the live production site and optimized to WebP+JPEG, JSON-LD structured data, `robots.txt`/`sitemap.xml`. No build tooling, no framework, no server required at runtime — deployable by copying files to any static host.

**Tech Stack:** Plain HTML5, plain CSS (custom properties, mobile-first, no preprocessor), vanilla JS (no jQuery/libraries), `sips` + `cwebp` + `qlmanage` (macOS built-ins) for one-time, dev-only image/icon processing.

## Global Constraints

- Canonical NAP, used verbatim everywhere (footer, header, JSON-LD): **Country Horizon RV Park**, **9212 W Main St, Ripley, OK 74062**, phone **918-399-9423** (Sholie, primary), email **chrvpark@gmail.com**.
- Secondary phone **918-399-9154** (Jeff) may appear only in the contact/footer area, never as the primary/schema number.
- Hours: **6:00 AM – 10:00 PM CST, daily** — must appear in the footer, a visible hours block, and JSON-LD `openingHoursSpecification`.
- Geo: latitude `35.98640`, longitude `-96.90234`.
- Never state the park is "in" Cushing — always "near Cushing" / "7 miles from Cushing" / proximity framing. The address in schema/footer is always the real Ripley address.
- Canonical origin for all absolute URLs: `https://countryhorizonrvpark.com` (no `www`, no trailing slash inconsistencies).
- Facebook: `https://www.facebook.com/CountryHorizonRVPark/`. No Google+ link anywhere (dead since 2019).
- No invented dollar figures for rates — use qualitative language ("monthly flat rates", "25% off daily rate for veterans") and a placeholder `priceRange` of `"$"` in schema; flag missing real rates in `ASSUMPTIONS.md`.
- Rules/amenities copy is written fresh (not copied verbatim from the live site), proofread, honest tone, matching the same 9 rule topics and amenity facts given in the brief.
- No third-party JS/services (no web fonts over network, no analytics, no form backend) — everything self-hosted or link-based (`tel:`, `mailto:`, Google Maps links).

---

## Task 1: Clean repo skeleton

**Files:**
- Delete: `app.js`, `bin/`, `routes/`, `node_modules/`, `package.json`, `public/index cp.html`, `public/partials/`, `public/shortcodes.html`, `public/contact.php`
- Delete: `public/css/`, `public/font/`, `public/images/`, `public/js/`, `public/logo.png`, `public/favicon.ico`, `public/index.html` (all template cruft — none of it is reused)
- Create: `css/`, `js/`, `img/park/original/` (empty dirs, populated in later tasks)

**Interfaces:**
- Produces: a flat repo root ready for `index.html`, `css/style.css`, `js/main.js`, `img/`, `robots.txt`, `sitemap.xml` to be added directly at the repo root (no `public/` wrapper — static hosts serve the repo root directly).

- [ ] **Step 1: Remove the Express/Jade scaffold and template cruft**

```bash
git rm -r --cached app.js bin routes node_modules package.json public
rm -rf app.js bin routes node_modules package.json public
```

- [ ] **Step 2: Create the new static-site directory skeleton**

```bash
mkdir -p css js img/park/original
```

- [ ] **Step 3: Verify the clean state**

Run: `find . -maxdepth 2 -not -path './.git*' -not -path './docs*' | sort`

Expected output (order may vary slightly):
```
.
./css
./img
./img/park
./img/park/original
./js
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove unused Express/Jade scaffold and template cruft"
```

---

## Task 2: Process real photo and logo assets

**Files:**
- Create: `img/park/original/image0.jpg` … `image4.jpg` (full-res originals, copied from the already-downloaded scratch copies)
- Create: `img/logo.svg`
- Create: `img/park/image0-800.jpg`, `image0-800.webp`, `image0-1600.jpg`, `image0-1600.webp`
- Create: `img/park/image1-800.jpg`, `image1-800.webp` (same pattern for `image2`, `image3`, `image4` — 800 only, no 1600 variant)
- Create: `img/favicon-512.png`, `img/favicon-32.png`, `img/apple-touch-icon.png`
- Create: `scripts/optimize-images.sh`

**Interfaces:**
- Produces (consumed by Task 5's `index.html`): exact image paths above. Hero uses `image0-800.webp`/`image0-800.jpg`/`image0-1600.webp`/`image0-1600.jpg` in a `<picture>` with `srcset`. Gallery uses `image0-800.*` through `image4-800.*`. Favicons: `img/logo.svg` (SVG icon), `img/favicon-32.png` (32×32 PNG icon), `img/apple-touch-icon.png` (180×180 apple-touch-icon). OG/Twitter image: `img/park/image0-1600.jpg`.

- [ ] **Step 1: Copy the already-downloaded real assets into the repo**

The real logo and 5 park photos were already downloaded and verified in this session at
`/private/tmp/claude-501/-Users-kolbeypruitt-Workspace-chrv/b78a8bb4-0441-4b12-acb1-ff592b00e4ee/scratchpad/chrv-source-check/img/`.

```bash
SCRATCH=/private/tmp/claude-501/-Users-kolbeypruitt-Workspace-chrv/b78a8bb4-0441-4b12-acb1-ff592b00e4ee/scratchpad/chrv-source-check
cp "$SCRATCH/img/chrv_logo.svg" img/logo.svg
cp "$SCRATCH/img/park/image0.jpg" img/park/original/image0.jpg
cp "$SCRATCH/img/park/image1.jpg" img/park/original/image1.jpg
cp "$SCRATCH/img/park/image2.jpg" img/park/original/image2.jpg
cp "$SCRATCH/img/park/image3.jpg" img/park/original/image3.jpg
cp "$SCRATCH/img/park/image4.jpg" img/park/original/image4.jpg
```

If the scratch directory is no longer available (new session), re-download instead:

```bash
curl -s "https://countryhorizonrvpark.com/img/chrv_logo.svg" -o img/logo.svg
for i in 0 1 2 3 4; do
  curl -s "https://countryhorizonrvpark.com/img/park/image$i.jpg" -o "img/park/original/image$i.jpg"
done
```

- [ ] **Step 2: Write the image optimization script**

Create `scripts/optimize-images.sh`:

```bash
#!/usr/bin/env bash
# Dev-time only. Regenerates optimized web assets from img/park/original/*.jpg
# and img/logo.svg. Requires macOS built-ins: sips, cwebp (brew install webp), qlmanage.
set -euo pipefail

SRC_DIR="img/park/original"
OUT_DIR="img/park"

resize_and_convert() {
  local name="$1" width="$2"
  local src="$SRC_DIR/${name}.jpg"
  local jpg_out="$OUT_DIR/${name}-${width}.jpg"
  local webp_out="$OUT_DIR/${name}-${width}.webp"
  sips -Z "$width" "$src" --out "$jpg_out" >/dev/null
  cwebp -quiet -q 78 "$jpg_out" -o "$webp_out"
}

for name in image0 image1 image2 image3 image4; do
  resize_and_convert "$name" 800
done
resize_and_convert image0 1600

# Favicons from the SVG logo
qlmanage -t -s 512 -o "$OUT_DIR/.." img/logo.svg >/dev/null
mv "img/logo.svg.png" img/favicon-512.png
sips -Z 180 img/favicon-512.png --out img/apple-touch-icon.png >/dev/null
sips -Z 32 img/favicon-512.png --out img/favicon-32.png >/dev/null

echo "Done. Generated files:"
ls -la "$OUT_DIR"/*.webp "$OUT_DIR"/*-800.jpg "$OUT_DIR"/*-1600.jpg img/favicon-*.png img/apple-touch-icon.png
```

- [ ] **Step 3: Make it executable and run it**

```bash
chmod +x scripts/optimize-images.sh
./scripts/optimize-images.sh
```

Expected: script prints a file listing ending with something like:
```
img/park/image0-1600.jpg
img/park/image0-1600.webp
img/park/image0-800.jpg
...
img/favicon-32.png
img/apple-touch-icon.png
```

- [ ] **Step 4: Verify dimensions and that WebP files are valid**

```bash
sips -g pixelWidth -g pixelHeight img/park/image0-1600.jpg img/park/image0-800.jpg img/apple-touch-icon.png img/favicon-32.png
file img/park/*.webp
```

Expected: `image0-1600.jpg` is `1600` wide, `image0-800.jpg` is `800` wide, `apple-touch-icon.png` is `180x180`, `favicon-32.png` is `32x32`, and every `.webp` file reports as `RIFF (little-endian) data, Web/P image`.

- [ ] **Step 5: Commit**

```bash
git add img scripts
git commit -m "feat: add real park photos, logo, and image optimization script"
```

---

## Task 3: Design system CSS

**Files:**
- Create: `css/style.css`

**Interfaces:**
- Produces (consumed by Task 5's `index.html`): CSS custom properties (`--color-primary`, `--color-primary-dark`, `--color-accent`, `--color-bg`, `--color-surface`, `--color-text`, `--color-text-muted`, `--color-border`), utility classes (`.container`, `.btn`, `.btn--primary`, `.btn--secondary`, `.visually-hidden`, `.skip-link`), component classes (`.site-header`, `.nav-toggle`, `.nav-menu`, `.hero`, `.hero__media`, `.hero__content`, `.hero__actions`, `.section`, `.section-title`, `.amenities-grid`, `.amenity-card`, `.amenity-icon`, `.rate-callout`, `.rules-list`, `.gallery-grid`, `.gallery-item`, `.location-grid`, `.map-embed`, `.faq-list`, `.faq-item`, `.site-footer`, `.footer-grid`), and the `is-open` state class toggled by `js/main.js` on `.nav-menu`.

- [ ] **Step 1: Write the complete stylesheet**

Create `css/style.css`:

```css
/* Country Horizon RV Park — base styles
   Color palette derived from the real park logo (teal camper + sun horizon). */

:root {
  --color-primary: #2c7d78;
  --color-primary-dark: #1c5450;
  --color-accent: #e0a72c;
  --color-bg: #fbf9f4;
  --color-surface: #ffffff;
  --color-text: #23292b;
  --color-text-muted: #55605c;
  --color-border: #e1dcc9;
  --radius: 10px;
  --shadow: 0 2px 10px rgba(35, 41, 43, 0.08);
  --max-width: 1120px;
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
}

*, *::before, *::after { box-sizing: border-box; }

html { scroll-behavior: smooth; }

body {
  margin: 0;
  font-family: var(--font-sans);
  color: var(--color-text);
  background: var(--color-bg);
  line-height: 1.55;
}

img { max-width: 100%; height: auto; display: block; }

h1, h2, h3 { line-height: 1.2; margin: 0 0 0.5em; }
h1 { font-size: clamp(1.9rem, 4vw + 1rem, 2.75rem); }
h2 { font-size: clamp(1.5rem, 2.5vw + 1rem, 2.1rem); }
h3 { font-size: 1.15rem; }
p { margin: 0 0 1em; }

a { color: var(--color-primary-dark); }
a:focus-visible, button:focus-visible, summary:focus-visible {
  outline: 3px solid var(--color-accent);
  outline-offset: 2px;
}

.container {
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 0 1.25rem;
}

.skip-link {
  position: absolute;
  left: -999px;
  top: 0;
  background: var(--color-primary-dark);
  color: #fff;
  padding: 0.75rem 1rem;
  z-index: 100;
}
.skip-link:focus { left: 0.5rem; top: 0.5rem; }

.visually-hidden {
  position: absolute;
  width: 1px; height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  white-space: nowrap;
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.9rem 1.4rem;
  border-radius: var(--radius);
  font-weight: 600;
  text-decoration: none;
  font-size: 1.05rem;
  border: 2px solid transparent;
  cursor: pointer;
}
.btn--primary {
  background: var(--color-accent);
  color: #23292b;
}
.btn--primary:hover { background: #cc9420; }
.btn--secondary {
  background: transparent;
  color: #fff;
  border-color: #fff;
}
.btn--secondary:hover { background: rgba(255,255,255,0.15); }

/* Header */
.site-header {
  position: sticky;
  top: 0;
  z-index: 50;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
}
.site-header .container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding-top: 0.6rem;
  padding-bottom: 0.6rem;
}
.logo-link {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  text-decoration: none;
  color: var(--color-text);
  font-weight: 700;
  font-size: 1.05rem;
}
.logo-link img { width: 44px; height: 44px; }

.nav-toggle {
  display: inline-flex;
  background: none;
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  padding: 0.5rem 0.7rem;
  font-size: 1.3rem;
  line-height: 1;
  cursor: pointer;
}

.nav-menu {
  display: none;
  flex-direction: column;
  position: absolute;
  left: 0; right: 0; top: 100%;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  padding: 0.5rem 1.25rem 1rem;
}
.nav-menu.is-open { display: flex; }
.nav-menu .nav-link {
  padding: 0.6rem 0;
  text-decoration: none;
  color: var(--color-text);
  font-weight: 600;
  border-bottom: 1px solid var(--color-border);
}
.nav-menu .nav-link:last-child { border-bottom: none; }

.header-call {
  white-space: nowrap;
  padding: 0.6rem 0.9rem;
  font-size: 0.95rem;
  background: var(--color-primary);
  color: #fff;
}
.header-call:hover { background: var(--color-primary-dark); }

/* Hero */
.hero { position: relative; color: #fff; }
.hero__media { position: relative; }
.hero__media img {
  width: 100%;
  height: 60vh;
  min-height: 360px;
  max-height: 640px;
  object-fit: cover;
}
.hero__media::after {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(28,84,80,0.55), rgba(28,84,80,0.82));
}
.hero__content {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 1.5rem;
}
.hero__content h1 { max-width: 44rem; }
.hero__subhead { max-width: 38rem; font-size: 1.1rem; }
.hero__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.9rem;
  justify-content: center;
  margin-top: 0.5rem;
}

/* Sections */
.section { padding: 3.5rem 0; }
.section--alt { background: var(--color-surface); }
.section-title { text-align: center; margin-bottom: 0.4rem; }
.section-intro {
  text-align: center;
  max-width: 42rem;
  margin: 0 auto 2.25rem;
  color: var(--color-text-muted);
}

/* Amenities */
.amenities-grid {
  display: grid;
  gap: 1.25rem;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
}
.amenity-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  padding: 1.4rem;
  box-shadow: var(--shadow);
}
.amenity-icon {
  width: 32px; height: 32px;
  color: var(--color-primary);
  margin-bottom: 0.6rem;
}
.amenity-card h3 { margin-bottom: 0.35rem; }
.amenity-card p { margin: 0; color: var(--color-text-muted); font-size: 0.96rem; }

/* Rates / veteran callout */
.rate-callout {
  background: var(--color-primary);
  color: #fff;
  border-radius: var(--radius);
  padding: 1.5rem 1.75rem;
  margin-top: 1.75rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}
.rate-callout h3 { margin: 0 0 0.25rem; }
.rate-callout p { margin: 0; }
.rate-callout .amenity-icon { color: #fff; }

/* Rules */
.rules-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 1.1rem;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
}
.rules-list li {
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  padding: 1.1rem 1.3rem;
}
.rules-list h3 { color: var(--color-primary-dark); margin-bottom: 0.3rem; }
.rules-list p { margin: 0; color: var(--color-text-muted); font-size: 0.96rem; }

/* Gallery */
.gallery-grid {
  display: grid;
  gap: 0.9rem;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
}
.gallery-item {
  display: block;
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow);
}
.gallery-item img { aspect-ratio: 4 / 3; object-fit: cover; width: 100%; }

/* Location / contact */
.location-grid {
  display: grid;
  gap: 2rem;
  grid-template-columns: 1fr;
}
.location-info address { font-style: normal; }
.hours-list { list-style: none; margin: 0.5rem 0 1.25rem; padding: 0; }
.hours-list li { display: flex; justify-content: space-between; max-width: 20rem; padding: 0.2rem 0; }
.contact-actions { display: flex; flex-wrap: wrap; gap: 0.8rem; margin-top: 1rem; }
.contact-actions .btn--primary { background: var(--color-accent); color: #23292b; }
.contact-actions .btn--outline {
  background: transparent;
  color: var(--color-primary-dark);
  border-color: var(--color-primary-dark);
}
.map-embed { border-radius: var(--radius); overflow: hidden; box-shadow: var(--shadow); }
.map-embed iframe { width: 100%; height: 340px; border: 0; display: block; }

/* FAQ */
.faq-list { max-width: 46rem; margin: 0 auto; }
.faq-item {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  padding: 0.9rem 1.2rem;
  margin-bottom: 0.8rem;
}
.faq-item summary {
  cursor: pointer;
  font-weight: 600;
  list-style: none;
}
.faq-item summary::-webkit-details-marker { display: none; }
.faq-item summary::after {
  content: "+";
  float: right;
  color: var(--color-primary);
  font-size: 1.3rem;
}
.faq-item[open] summary::after { content: "\2212"; }
.faq-item p { margin: 0.7rem 0 0; color: var(--color-text-muted); }

/* Footer */
.site-footer {
  background: var(--color-primary-dark);
  color: #eef4f3;
  padding: 3rem 0 1.5rem;
}
.footer-grid {
  display: grid;
  gap: 2rem;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  margin-bottom: 2rem;
}
.footer-grid h3 { color: #fff; font-size: 1rem; margin-bottom: 0.6rem; }
.footer-grid address, .footer-grid p { margin: 0; font-style: normal; color: #cfe0dd; font-size: 0.95rem; }
.footer-grid a { color: #eef4f3; }
.footer-links { list-style: none; margin: 0; padding: 0; }
.footer-links li { margin-bottom: 0.4rem; }
.footer-bottom {
  border-top: 1px solid rgba(255,255,255,0.15);
  padding-top: 1.25rem;
  text-align: center;
  font-size: 0.85rem;
  color: #b9cdc9;
}

/* Responsive */
@media (min-width: 720px) {
  .nav-toggle { display: none; }
  .nav-menu {
    display: flex;
    position: static;
    flex-direction: row;
    border: 0;
    padding: 0;
    background: none;
    gap: 1.5rem;
  }
  .nav-menu .nav-link { border-bottom: 0; padding: 0.3rem 0; }
  .location-grid { grid-template-columns: 1.1fr 1fr; align-items: start; }
}

@media (min-width: 960px) {
  .section { padding: 5rem 0; }
}
```

- [ ] **Step 2: Verify the file is syntactically valid CSS**

Run: `node -e "require('fs').readFileSync('css/style.css','utf8'); console.log('read ok, length', require('fs').statSync('css/style.css').size)"`

Expected: prints `read ok, length <some number greater than 5000>` with no errors.

- [ ] **Step 3: Commit**

```bash
git add css/style.css
git commit -m "feat: add mobile-first design system stylesheet"
```

---

## Task 4: Site JavaScript

**Files:**
- Create: `js/main.js`

**Interfaces:**
- Consumes (from Task 5's `index.html`): element `#nav-toggle` (button, `aria-controls="primary-nav"`, `aria-expanded`), element `#primary-nav` (the `.nav-menu`), all `#primary-nav .nav-link` anchors, element `#year` (span inside the footer copyright line).
- Produces: no globals beyond the IIFE's internal scope; behavior only.

- [ ] **Step 1: Write the script**

Create `js/main.js`:

```js
(function () {
  "use strict";

  var toggle = document.getElementById("nav-toggle");
  var nav = document.getElementById("primary-nav");

  if (toggle && nav) {
    toggle.addEventListener("click", function () {
      var isOpen = nav.classList.toggle("is-open");
      toggle.setAttribute("aria-expanded", isOpen ? "true" : "false");
    });

    nav.querySelectorAll(".nav-link").forEach(function (link) {
      link.addEventListener("click", function () {
        nav.classList.remove("is-open");
        toggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  var yearEl = document.getElementById("year");
  if (yearEl) {
    yearEl.textContent = String(new Date().getFullYear());
  }
})();
```

- [ ] **Step 2: Verify the file has no syntax errors**

Run: `node --check js/main.js`

Expected: no output, exit code 0.

- [ ] **Step 3: Commit**

```bash
git add js/main.js
git commit -m "feat: add nav toggle and dynamic copyright year script"
```

---

## Task 5: Build index.html

**Files:**
- Create: `index.html`

**Interfaces:**
- Consumes: every class name and image path produced in Tasks 2–4 (see those tasks' "Produces" lists).
- Produces: the complete page. Anchors `#home`, `#amenities`, `#rates`, `#rules`, `#photos`, `#location`, `#faq` must exist and match the nav links exactly (consumed by manual/browser verification in Task 8).

- [ ] **Step 1: Write the complete page**

Create `index.html`:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Country Horizon RV Park | RV Park near Cushing, OK</title>
<meta name="description" content="Quiet 9-site RV park near Cushing, OK with full 30/50-amp hookups, well water, sewer &amp; WiFi. Monthly &amp; daily rates. Veterans save 25%. Call today!">
<link rel="canonical" href="https://countryhorizonrvpark.com/">

<link rel="icon" href="img/logo.svg" type="image/svg+xml">
<link rel="icon" href="img/favicon-32.png" sizes="32x32" type="image/png">
<link rel="apple-touch-icon" href="img/apple-touch-icon.png">

<meta property="og:type" content="business.business">
<meta property="og:title" content="Country Horizon RV Park | RV Park near Cushing, OK">
<meta property="og:description" content="Quiet 9-site RV park near Cushing, OK with full 30/50-amp hookups, well water, sewer &amp; WiFi. Monthly &amp; daily rates. Veterans save 25%.">
<meta property="og:url" content="https://countryhorizonrvpark.com/">
<meta property="og:image" content="https://countryhorizonrvpark.com/img/park/image0-1600.jpg">
<meta property="og:locale" content="en_US">

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Country Horizon RV Park | RV Park near Cushing, OK">
<meta name="twitter:description" content="Quiet 9-site RV park near Cushing, OK with full 30/50-amp hookups, well water, sewer &amp; WiFi. Monthly &amp; daily rates. Veterans save 25%.">
<meta name="twitter:image" content="https://countryhorizonrvpark.com/img/park/image0-1600.jpg">

<link rel="stylesheet" href="css/style.css">

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Campground",
  "name": "Country Horizon RV Park",
  "image": [
    "https://countryhorizonrvpark.com/img/park/image0-1600.jpg",
    "https://countryhorizonrvpark.com/img/park/image1-800.jpg",
    "https://countryhorizonrvpark.com/img/park/image2-800.jpg"
  ],
  "url": "https://countryhorizonrvpark.com/",
  "telephone": "+1-918-399-9423",
  "email": "chrvpark@gmail.com",
  "priceRange": "$",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "9212 W Main St",
    "addressLocality": "Ripley",
    "addressRegion": "OK",
    "postalCode": "74062",
    "addressCountry": "US"
  },
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": 35.98640,
    "longitude": -96.90234
  },
  "openingHoursSpecification": {
    "@type": "OpeningHoursSpecification",
    "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
    "opens": "06:00",
    "closes": "22:00"
  },
  "sameAs": [
    "https://www.facebook.com/CountryHorizonRVPark/",
    "https://twitter.com/chrvpark"
  ],
  "amenityFeature": [
    { "@type": "LocationFeatureSpecification", "name": "30 Amp Electric Hookup", "value": true },
    { "@type": "LocationFeatureSpecification", "name": "50 Amp Electric Hookup", "value": true },
    { "@type": "LocationFeatureSpecification", "name": "Water Hookup", "value": true },
    { "@type": "LocationFeatureSpecification", "name": "Sewer Hookup", "value": true },
    { "@type": "LocationFeatureSpecification", "name": "Free WiFi", "value": true },
    { "@type": "LocationFeatureSpecification", "name": "Pet Friendly", "value": true }
  ],
  "areaServed": [
    { "@type": "City", "name": "Cushing", "containedInPlace": { "@type": "State", "name": "Oklahoma" } },
    { "@type": "City", "name": "Stillwater", "containedInPlace": { "@type": "State", "name": "Oklahoma" } },
    { "@type": "City", "name": "Perkins", "containedInPlace": { "@type": "State", "name": "Oklahoma" } },
    { "@type": "City", "name": "Ripley", "containedInPlace": { "@type": "State", "name": "Oklahoma" } }
  ]
}
</script>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do you offer monthly rates?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes — we offer competitive monthly flat rates in addition to daily rates, popular with pipeline and oil-field workers, long-term travelers, and OSU-area visitors. Call Sholie at 918-399-9423 for current rates and availability."
      }
    },
    {
      "@type": "Question",
      "name": "Are pets allowed?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, well-behaved pets are welcome on a leash. Owners are responsible for cleaning up after their pets and for any damage or injury they cause."
      }
    },
    {
      "@type": "Question",
      "name": "Do you have 50 amp hookups?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Every one of our 9 graveled sites is 35 feet wide with full hookups, including both 30-amp and 50-amp electric service, well water, and sewer."
      }
    },
    {
      "@type": "Question",
      "name": "How far is the park from Cushing, OK?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Country Horizon RV Park sits at the intersection of HWY 33 and HWY 108 in Ripley, OK — about 7 miles (roughly 10-15 minutes) from Cushing, and a short drive from Stillwater and Perkins."
      }
    },
    {
      "@type": "Question",
      "name": "Is there a discount for veterans?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. As a thank-you for your service, veterans receive 25% off our daily rate."
      }
    },
    {
      "@type": "Question",
      "name": "What's included with a site?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Every site includes 30/50-amp electric, water and sewer hookups, free WiFi, dumpster access, and a mailbox for guests staying longer term."
      }
    }
  ]
}
</script>
</head>
<body>
<a class="skip-link" href="#main">Skip to content</a>

<svg xmlns="http://www.w3.org/2000/svg" class="visually-hidden" aria-hidden="true">
  <symbol id="icon-bolt" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon>
  </symbol>
  <symbol id="icon-droplet" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"></path>
  </symbol>
  <symbol id="icon-wifi" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M5 12.55a11 11 0 0 1 14.08 0"></path>
    <path d="M1.42 9a16 16 0 0 1 21.16 0"></path>
    <path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path>
    <line x1="12" y1="20" x2="12.01" y2="20"></line>
  </symbol>
  <symbol id="icon-trash" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <polyline points="3 6 5 6 21 6"></polyline>
    <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
  </symbol>
  <symbol id="icon-mail" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z"></path>
    <polyline points="22 6 12 13 2 6"></polyline>
  </symbol>
  <symbol id="icon-paw" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="7" cy="7" r="2"></circle>
    <circle cx="12" cy="5" r="2"></circle>
    <circle cx="17" cy="7" r="2"></circle>
    <path d="M6 13c0-2 2.5-3 6-3s6 1 6 3-1 6-6 6-6-4-6-6z"></path>
  </symbol>
  <symbol id="icon-maximize" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"></path>
  </symbol>
  <symbol id="icon-star" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
  </symbol>
</svg>

<header class="site-header">
  <div class="container">
    <a class="logo-link" href="#home">
      <img src="img/logo.svg" alt="" width="44" height="44">
      Country Horizon RV Park
    </a>
    <button class="nav-toggle" id="nav-toggle" aria-controls="primary-nav" aria-expanded="false" aria-label="Toggle navigation menu">&#9776;</button>
    <nav class="nav-menu" id="primary-nav" aria-label="Primary">
      <a class="nav-link" href="#amenities">Amenities</a>
      <a class="nav-link" href="#rates">Rates</a>
      <a class="nav-link" href="#rules">Park Rules</a>
      <a class="nav-link" href="#photos">Photos</a>
      <a class="nav-link" href="#location">Location &amp; Contact</a>
      <a class="nav-link" href="#faq">FAQ</a>
      <a class="nav-link header-call btn btn--primary" href="tel:19183999423">Call 918-399-9423</a>
    </nav>
  </div>
</header>

<main id="main">

<section class="hero" id="home">
  <div class="hero__media">
    <picture>
      <source type="image/webp" srcset="img/park/image0-800.webp 800w, img/park/image0-1600.webp 1600w" sizes="100vw">
      <img src="img/park/image0-1600.jpg" srcset="img/park/image0-800.jpg 800w, img/park/image0-1600.jpg 1600w" sizes="100vw" width="1600" height="898" alt="Gravel RV sites with travel trailers parked among trees at Country Horizon RV Park" fetchpriority="high">
    </picture>
  </div>
  <div class="hero__content">
    <h1>Country Horizon RV Park &mdash; Quiet Country RV Park near Cushing, Oklahoma</h1>
    <p class="hero__subhead">9 spacious, 35-ft graveled sites with full 30/50-amp hookups, well water &amp; sewer &mdash; just 7 miles from Cushing, OK. Monthly and daily rates available. Veterans save 25%.</p>
    <div class="hero__actions">
      <a class="btn btn--primary" href="tel:19183999423">Call 918-399-9423</a>
      <a class="btn btn--secondary" href="#location">Get Directions</a>
    </div>
  </div>
</section>

<section class="section" id="amenities">
  <div class="container">
    <h2 class="section-title">Full Hookups &amp; Amenities</h2>
    <p class="section-intro">Every one of our 9 graveled sites is 35 feet wide, with room to park and set up with ease.</p>
    <div class="amenities-grid">
      <div class="amenity-card">
        <svg class="amenity-icon" aria-hidden="true"><use href="#icon-bolt"></use></svg>
        <h3>30/50 Amp Electric</h3>
        <p>Every site offers both 30-amp and 50-amp electric service, ready for any rig.</p>
      </div>
      <div class="amenity-card">
        <svg class="amenity-icon" aria-hidden="true"><use href="#icon-droplet"></use></svg>
        <h3>Water &amp; Sewer</h3>
        <p>Fresh water from our private well and full sewer hookups at every site.</p>
      </div>
      <div class="amenity-card">
        <svg class="amenity-icon" aria-hidden="true"><use href="#icon-wifi"></use></svg>
        <h3>Free WiFi</h3>
        <p>Complimentary WiFi across the park, included with every stay.</p>
      </div>
      <div class="amenity-card">
        <svg class="amenity-icon" aria-hidden="true"><use href="#icon-trash"></use></svg>
        <h3>Trash &amp; Dumpster</h3>
        <p>On-site dumpster service &mdash; no need to haul your trash off-site.</p>
      </div>
      <div class="amenity-card">
        <svg class="amenity-icon" aria-hidden="true"><use href="#icon-mail"></use></svg>
        <h3>Mailboxes</h3>
        <p>Individual mailboxes for long-term tenants staying month to month.</p>
      </div>
      <div class="amenity-card">
        <svg class="amenity-icon" aria-hidden="true"><use href="#icon-paw"></use></svg>
        <h3>Pet Friendly</h3>
        <p>Leashed pets are welcome. Please clean up after your pet.</p>
      </div>
      <div class="amenity-card">
        <svg class="amenity-icon" aria-hidden="true"><use href="#icon-maximize"></use></svg>
        <h3>35 ft Graveled Sites</h3>
        <p>9 spacious, 35-foot-wide graveled sites with plenty of room to park and set up.</p>
      </div>
      <div class="amenity-card">
        <svg class="amenity-icon" aria-hidden="true"><use href="#icon-star"></use></svg>
        <h3>Veteran Discount</h3>
        <p>Veterans save 25% off our daily rate as a thank-you for your service.</p>
      </div>
    </div>
  </div>
</section>

<section class="section section--alt" id="rates">
  <div class="container">
    <h2 class="section-title">Monthly RV Sites near Cushing, OK</h2>
    <p class="section-intro">Country Horizon RV Park is a popular home base for pipeline and oil-field crews working monthly contracts in Cushing, along with long-term travelers and seasonal guests.</p>
    <p>We offer both daily and competitive monthly flat rates. Because Cushing is a major oil pipeline hub, many of our long-term guests are pipeline and oil-field workers on monthly assignments &mdash; we also welcome RV travelers passing through, and visitors to nearby Stillwater and Oklahoma State University. Call or text Sholie at <a href="tel:19183999423">918-399-9423</a> for current rates and availability.</p>
    <div class="rate-callout">
      <svg class="amenity-icon" aria-hidden="true"><use href="#icon-star"></use></svg>
      <div>
        <h3>Veterans save 25%</h3>
        <p>If you're traveling through our area, we offer 25% off our daily rate for all veterans. Thank you for your service.</p>
      </div>
    </div>
  </div>
</section>

<section class="section" id="rules">
  <div class="container">
    <h2 class="section-title">Park Rules</h2>
    <p class="section-intro">A few simple rules keep Country Horizon a quiet, well-kept place for everyone.</p>
    <ol class="rules-list">
      <li>
        <h3>Quiet Hours</h3>
        <p>Quiet hours run from 10:00 PM to 7:00 AM. Please keep noise to a minimum out of respect for your neighbors.</p>
      </li>
      <li>
        <h3>Speed Limit</h3>
        <p>The speed limit throughout the park is 5&ndash;10 mph. Please don't peel out or spin gravel.</p>
      </li>
      <li>
        <h3>Responsible Guests</h3>
        <p>The person registered for a site is financially responsible for the conduct of their guests.</p>
      </li>
      <li>
        <h3>Pets</h3>
        <p>Pets must be leashed at all times when outside your RV and never left unattended. Please clean up after your pet &mdash; owners are responsible for any damage or injury their pet causes.</p>
      </li>
      <li>
        <h3>Children</h3>
        <p>Children must be supervised by a parent or guardian at all times. Parents and guardians are responsible for any damage caused by their children.</p>
      </li>
      <li>
        <h3>Trash</h3>
        <p>Please place all trash in the provided dumpster. Don't leave trash outside your RV, and keep your site neat and clean.</p>
      </li>
      <li>
        <h3>Cigarettes</h3>
        <p>Please extinguish cigarettes fully and dispose of them properly &mdash; never on the ground.</p>
      </li>
      <li>
        <h3>Water Leaks</h3>
        <p>Please report any water leaks right away. Excessive water waste is not permitted and must be fixed promptly.</p>
      </li>
      <li>
        <h3>Drugs</h3>
        <p>Illegal substances are strictly prohibited on the property and will result in immediate removal from the park.</p>
      </li>
    </ol>
  </div>
</section>

<section class="section section--alt" id="photos">
  <div class="container">
    <h2 class="section-title">Photos</h2>
    <p class="section-intro">A look around Country Horizon RV Park.</p>
    <div class="gallery-grid">
      <a class="gallery-item" href="img/park/original/image0.jpg" target="_blank" rel="noopener">
        <picture>
          <source type="image/webp" srcset="img/park/image0-800.webp">
          <img src="img/park/image0-800.jpg" width="800" height="449" loading="lazy" alt="Gravel RV sites with travel trailers parked among trees at Country Horizon RV Park">
        </picture>
      </a>
      <a class="gallery-item" href="img/park/original/image1.jpg" target="_blank" rel="noopener">
        <picture>
          <source type="image/webp" srcset="img/park/image1-800.webp">
          <img src="img/park/image1-800.jpg" width="800" height="452" loading="lazy" alt="Park entrance sign with several RVs parked in a row and the on-site storage building">
        </picture>
      </a>
      <a class="gallery-item" href="img/park/original/image2.jpg" target="_blank" rel="noopener">
        <picture>
          <source type="image/webp" srcset="img/park/image2-800.webp">
          <img src="img/park/image2-800.jpg" width="800" height="450" loading="lazy" alt="Empty freshly graveled 35-foot-wide RV site with hookup pedestals ready for setup">
        </picture>
      </a>
      <a class="gallery-item" href="img/park/original/image3.jpg" target="_blank" rel="noopener">
        <picture>
          <source type="image/webp" srcset="img/park/image3-800.webp">
          <img src="img/park/image3-800.jpg" width="800" height="450" loading="lazy" alt="Evening view of the open grounds and storage building at Country Horizon RV Park">
        </picture>
      </a>
      <a class="gallery-item" href="img/park/original/image4.jpg" target="_blank" rel="noopener">
        <picture>
          <source type="image/webp" srcset="img/park/image4-800.webp">
          <img src="img/park/image4-800.jpg" width="800" height="450" loading="lazy" alt="Close-up of a site's 30/50-amp electric hookup pedestal and water spigot">
        </picture>
      </a>
    </div>
  </div>
</section>

<section class="section" id="location">
  <div class="container">
    <h2 class="section-title">Location &amp; Directions</h2>
    <div class="location-grid">
      <div class="location-info">
        <p>Country Horizon RV Park sits in the quiet countryside of Ripley, Oklahoma, right at the intersection of HWY 33 and HWY 108 &mdash; easy highway access for RVs and heavy trucks alike. We're about 7 miles (10&ndash;15 minutes) from Cushing, OK, a major oil pipeline hub, making us a convenient home base for pipeline and oil-field crews working monthly contracts. We're also a short drive from Stillwater (home of Oklahoma State University) and neighboring Perkins, putting travelers, OSU visitors, and RVers passing through central Oklahoma within easy reach.</p>

        <h2>Contact &amp; Reservations</h2>
        <address>
          Country Horizon RV Park<br>
          9212 W Main St<br>
          Ripley, OK 74062
        </address>
        <p>
          Phone: <a href="tel:19183999423">918-399-9423</a> (Sholie)<br>
          Alt. phone: <a href="tel:19183999154">918-399-9154</a> (Jeff)<br>
          Email: <a href="mailto:chrvpark@gmail.com">chrvpark@gmail.com</a>
        </p>
        <h3>Hours</h3>
        <ul class="hours-list">
          <li><span>Every day</span> <span>6:00 AM &ndash; 10:00 PM CST</span></li>
        </ul>
        <div class="contact-actions">
          <a class="btn btn--primary" href="tel:19183999423">Call 918-399-9423</a>
          <a class="btn btn--outline" href="mailto:chrvpark@gmail.com">Email Us</a>
          <a class="btn btn--outline" href="https://www.google.com/maps/dir/?api=1&amp;destination=9212+W+Main+St,+Ripley,+OK+74062" target="_blank" rel="noopener">Get Directions</a>
        </div>
      </div>
      <div class="map-embed">
        <iframe src="https://www.google.com/maps?q=35.98640,-96.90234&amp;z=15&amp;output=embed" loading="lazy" title="Map showing the location of Country Horizon RV Park in Ripley, OK" referrerpolicy="no-referrer-when-downgrade"></iframe>
      </div>
    </div>
  </div>
</section>

<section class="section section--alt" id="faq">
  <div class="container">
    <h2 class="section-title">Frequently Asked Questions</h2>
    <div class="faq-list">
      <details class="faq-item">
        <summary>Do you offer monthly rates?</summary>
        <p>Yes &mdash; we offer competitive monthly flat rates in addition to daily rates, popular with pipeline and oil-field workers, long-term travelers, and OSU-area visitors. Call Sholie at 918-399-9423 for current rates and availability.</p>
      </details>
      <details class="faq-item">
        <summary>Are pets allowed?</summary>
        <p>Yes, well-behaved pets are welcome on a leash. Owners are responsible for cleaning up after their pets and for any damage or injury they cause.</p>
      </details>
      <details class="faq-item">
        <summary>Do you have 50 amp hookups?</summary>
        <p>Yes. Every one of our 9 graveled sites is 35 feet wide with full hookups, including both 30-amp and 50-amp electric service, well water, and sewer.</p>
      </details>
      <details class="faq-item">
        <summary>How far is the park from Cushing, OK?</summary>
        <p>Country Horizon RV Park sits at the intersection of HWY 33 and HWY 108 in Ripley, OK &mdash; about 7 miles (roughly 10&ndash;15 minutes) from Cushing, and a short drive from Stillwater and Perkins.</p>
      </details>
      <details class="faq-item">
        <summary>Is there a discount for veterans?</summary>
        <p>Yes. As a thank-you for your service, veterans receive 25% off our daily rate.</p>
      </details>
      <details class="faq-item">
        <summary>What's included with a site?</summary>
        <p>Every site includes 30/50-amp electric, water and sewer hookups, free WiFi, dumpster access, and a mailbox for guests staying longer term.</p>
      </details>
    </div>
  </div>
</section>

</main>

<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <h3>Country Horizon RV Park</h3>
        <address>
          9212 W Main St<br>
          Ripley, OK 74062
        </address>
      </div>
      <div>
        <h3>Contact</h3>
        <p>Phone: <a href="tel:19183999423">918-399-9423</a> (Sholie)<br>
        Alt: <a href="tel:19183999154">918-399-9154</a> (Jeff)<br>
        Email: <a href="mailto:chrvpark@gmail.com">chrvpark@gmail.com</a></p>
      </div>
      <div>
        <h3>Hours</h3>
        <p>Open daily<br>6:00 AM &ndash; 10:00 PM CST</p>
      </div>
      <div>
        <h3>Quick Links</h3>
        <ul class="footer-links">
          <li><a href="#amenities">Amenities</a></li>
          <li><a href="#rates">Rates</a></li>
          <li><a href="#rules">Park Rules</a></li>
          <li><a href="#photos">Photos</a></li>
          <li><a href="#faq">FAQ</a></li>
          <li><a href="https://www.facebook.com/CountryHorizonRVPark/" target="_blank" rel="noopener">Facebook</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> Country Horizon RV Park. All rights reserved.
    </div>
  </div>
</footer>

<script src="js/main.js" defer></script>
</body>
</html>
```

- [ ] **Step 2: Verify the HTML parses and required elements exist**

Run:
```bash
node -e "
const fs = require('fs');
const html = fs.readFileSync('index.html', 'utf8');
const checks = [
  ['<title>Country Horizon RV Park', html.includes('<title>Country Horizon RV Park')],
  ['single h1', (html.match(/<h1/g) || []).length === 1],
  ['no Google+ link', !html.includes('plus.google.com')],
  ['correct Facebook link', html.includes('https://www.facebook.com/CountryHorizonRVPark/')],
  ['canonical tag', html.includes('rel=\"canonical\" href=\"https://countryhorizonrvpark.com/\"')],
  ['primary phone tel link', html.includes('tel:19183999423')],
  ['email mailto link', html.includes('mailto:chrvpark@gmail.com')],
  ['no Quite Hours typo', !html.includes('Quite Hours')],
  ['no Accomadations typo', !html.includes('Accomadations')],
  ['says extinguish not distinguish (cigarette rule)', html.includes('extinguish cigarettes')],
];
let ok = true;
for (const [label, pass] of checks) {
  console.log((pass ? 'PASS' : 'FAIL') + ' - ' + label);
  if (!pass) ok = false;
}
process.exit(ok ? 0 : 1);
"
```

Expected: every line prints `PASS`, exit code 0.

- [ ] **Step 3: Verify title and meta description lengths**

```bash
node -e "
const fs = require('fs');
const html = fs.readFileSync('index.html', 'utf8');
const title = html.match(/<title>(.*?)<\/title>/)[1];
const desc = html.match(/name=\"description\" content=\"(.*?)\"/)[1];
console.log('title length:', title.length);
console.log('description length:', desc.length);
"
```

Expected: title length is at or near 52 (well under 60); description length is under 160.

- [ ] **Step 4: Validate both JSON-LD blocks parse as valid JSON**

```bash
node -e "
const fs = require('fs');
const html = fs.readFileSync('index.html', 'utf8');
const blocks = [...html.matchAll(/<script type=\"application\/ld\+json\">([\s\S]*?)<\/script>/g)];
console.log('found', blocks.length, 'ld+json blocks');
blocks.forEach((b, i) => {
  const obj = JSON.parse(b[1]);
  console.log('block', i, '@type =', obj['@type']);
});
"
```

Expected:
```
found 2 ld+json blocks
block 0 @type = Campground
block 1 @type = FAQPage
```
(No `JSON.parse` errors thrown.)

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: build production index.html with real content, schema, and SEO tags"
```

---

## Task 6: robots.txt and sitemap.xml

**Files:**
- Create: `robots.txt`
- Create: `sitemap.xml`

- [ ] **Step 1: Write robots.txt**

Create `robots.txt`:

```
User-agent: *
Allow: /

Sitemap: https://countryhorizonrvpark.com/sitemap.xml
```

- [ ] **Step 2: Write sitemap.xml**

Create `sitemap.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://countryhorizonrvpark.com/</loc>
    <lastmod>2026-07-14</lastmod>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

- [ ] **Step 3: Verify sitemap.xml is well-formed XML**

```bash
node -e "
const { execSync } = require('child_process');
const fs = require('fs');
const xml = fs.readFileSync('sitemap.xml', 'utf8');
if (!xml.includes('<loc>https://countryhorizonrvpark.com/</loc>')) throw new Error('missing loc');
if (!/^<\?xml/.test(xml)) throw new Error('missing xml declaration');
console.log('sitemap.xml OK');
"
```

Expected: `sitemap.xml OK`.

- [ ] **Step 4: Commit**

```bash
git add robots.txt sitemap.xml
git commit -m "feat: add robots.txt and sitemap.xml"
```

---

## Task 7: DEPLOY.md and ASSUMPTIONS.md

**Files:**
- Create: `DEPLOY.md`
- Create: `ASSUMPTIONS.md`

- [ ] **Step 1: Write DEPLOY.md**

Create `DEPLOY.md`:

```markdown
# Deploying Country Horizon RV Park

This is a fully static site — `index.html`, `css/`, `js/`, `img/`, `robots.txt`,
`sitemap.xml` at the repo root. No build step, no server, no database.

## Deploy (any of these work)

- **Netlify / Cloudflare Pages / Vercel (static)**: connect the repo, leave the
  build command empty, set the publish directory to `/` (repo root).
- **GitHub Pages**: enable Pages on this repo, source = root of the default branch.
- **Any plain web host / S3 bucket / shared hosting**: upload the repo root
  contents via FTP/SFTP or `aws s3 sync . s3://your-bucket`.

## Before going live — required

1. **Pick ONE canonical domain form** and make every other form redirect to it:
   `https://countryhorizonrvpark.com` (no `www`, no `http://`). All meta tags,
   the canonical link, and JSON-LD in `index.html` already assume this exact
   origin — if the real canonical domain differs, update every
   `https://countryhorizonrvpark.com` occurrence in `index.html`, `robots.txt`,
   and `sitemap.xml` to match.
2. **Point DNS** at your chosen host and set up automatic `www` → non-`www` and
   `http` → `https` redirects (most hosts above do this with one checkbox/setting).

## After going live

1. **Google Search Console**: verify ownership of `https://countryhorizonrvpark.com`,
   then submit `https://countryhorizonrvpark.com/sitemap.xml`.
2. **Google Business Profile**: cross-check the address, phone, and hours listed
   there against this site (see `ASSUMPTIONS.md` — the address format and hours
   were provided by the owner during this rebuild but were not directly verified
   against the live Google Business Profile). Consistent NAP across the website
   and Google Business Profile is the single biggest fix for the "permanently
   closed" flag.
3. **Rich Results Test**: paste `https://countryhorizonrvpark.com/` into
   Google's Rich Results Test to confirm the `Campground` and `FAQPage`
   structured data are recognized with no errors.
4. **Rates**: `index.html`'s `priceRange` is set to a placeholder `"$"` and the
   on-page copy intentionally avoids naming a dollar figure (none was provided).
   If you want real numbers to appear (recommended for conversion), edit the
   `priceRange` value in the JSON-LD `Campground` block and the "Monthly RV
   Sites near Cushing, OK" section copy in `index.html`.

## Adding or replacing photos later

1. Drop new full-resolution JPEGs into `img/park/original/`.
2. Update `scripts/optimize-images.sh` if filenames differ from `image0`…`image4`.
3. Run `./scripts/optimize-images.sh` (requires macOS `sips` + Homebrew `cwebp`:
   `brew install webp`) to regenerate the WebP/resized variants.
4. Update the `<picture>`/`<img>` `src`, `srcset`, `alt`, `width`, and `height`
   in `index.html`'s gallery section to match.
```

- [ ] **Step 2: Write ASSUMPTIONS.md**

Create `ASSUMPTIONS.md`:

```markdown
# Assumptions made during this rebuild

- **Repo did not contain the real site.** The original repo was a generic 2014
  agency template with lorem ipsum content; none of the RV-park-specific copy,
  photos, or rules text existed in it. All real facts were pulled from the live
  production site (`https://countryhorizonrvpark.com/`) during this session and
  from the business owner directly.
- **Address format** ("9212 W Main St, Ripley, OK 74062") is assumed correct as
  written, since it matches both the live site and the business owner's brief
  verbatim. It was not independently cross-checked against USPS or the Google
  Business Profile — do that before relying on it for mail delivery accuracy.
- **Email** (`chrvpark@gmail.com`) was decoded directly from the live site's
  Cloudflare email-obfuscation markup, not just taken on faith from the brief —
  high confidence.
- **Hours** (6:00 AM–10:00 PM CST, daily) were provided directly by the
  business owner. The live site listed no hours at all previously. These hours
  have NOT been cross-checked against the Google Business Profile — please
  confirm the two match exactly, since mismatched hours between the website and
  Google Business Profile is a common cause of Google's "permanently closed"
  flag (the same issue this rebuild is trying to fix).
- **Park rules and amenities copy were rewritten from scratch**, not copied
  verbatim from the live site, per the owner's explicit choice. Same 9 rule
  topics and the same amenities/facts, proofread and rewritten in the process.
- **No real dollar rates were given.** `priceRange` in the structured data uses
  a placeholder value (`"$"`) and on-page copy deliberately avoids naming a
  specific number. Add real rates before launch if you want them to appear.
- **Photos**: the 5 real photos and the real logo were downloaded directly from
  the live site (`https://countryhorizonrvpark.com/img/...`) and optimized
  (resized + WebP) for this rebuild — not stock or placeholder images.
- **Social links**: Facebook was updated to
  `https://www.facebook.com/CountryHorizonRVPark/` per the owner's confirmation.
  The live site's Twitter (`twitter.com/chrvpark`) was kept as-is since it's a
  real, non-dead account; verify it's still active/monitored before keeping it
  in the footer and schema `sameAs`.
- **Single-page architecture**: chosen over a multi-page site, matching the
  live site's existing structure and appropriate for a 9-space business —
  avoids diluting topical SEO authority across several thin pages.
- **No contact form**: the live site posted a contact form to `contact.php`,
  which can't run on a static host. This rebuild replaces it with direct
  `tel:`/`mailto:` call-to-action buttons instead of adding a third-party form
  service that wasn't requested.
```

- [ ] **Step 3: Commit**

```bash
git add DEPLOY.md ASSUMPTIONS.md
git commit -m "docs: add deployment guide and assumptions log"
```

---

## Task 8: Final verification pass

**Files:** none created; this task only verifies Tasks 1–7's output.

- [ ] **Step 1: Serve the site locally**

```bash
python3 -m http.server 8123 --directory . &
sleep 1
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8123/
```

Expected: `200`.

- [ ] **Step 2: Verify every asset referenced in index.html actually resolves (no 404s)**

```bash
node -e "
const fs = require('fs');
const html = fs.readFileSync('index.html', 'utf8');
const paths = new Set();
for (const m of html.matchAll(/(?:src|srcset|href)=\"([^\"]+)\"/g)) {
  for (const part of m[1].split(',')) {
    const p = part.trim().split(' ')[0];
    if (p && !p.startsWith('http') && !p.startsWith('tel:') && !p.startsWith('mailto:') && !p.startsWith('#')) {
      paths.add(p);
    }
  }
}
let missing = [];
for (const p of paths) {
  if (!fs.existsSync(p)) missing.push(p);
}
console.log('checked', paths.size, 'local paths');
if (missing.length) { console.log('MISSING:', missing); process.exit(1); }
console.log('all local asset paths resolve');
"
```

Expected: `all local asset paths resolve`, exit code 0.

- [ ] **Step 3: Load the page in a real browser and check for console errors, using Playwright**

Use the `mcp__plugin_ecc_playwright__browser_navigate` tool to open `http://localhost:8123/`,
then `mcp__plugin_ecc_playwright__browser_console_messages` to confirm there are no `error`-level
entries, then `mcp__plugin_ecc_playwright__browser_take_screenshot` at default desktop size.

Expected: no console errors; screenshot shows the hero section with the real photo, heading,
and call-to-action buttons rendered correctly.

- [ ] **Step 4: Check the mobile viewport**

Use `mcp__plugin_ecc_playwright__browser_resize` to `375x812` (iPhone-sized), then
`mcp__plugin_ecc_playwright__browser_take_screenshot` again, and click the nav toggle button
via `mcp__plugin_ecc_playwright__browser_click` to confirm the mobile menu opens.

Expected: layout has no horizontal overflow, the hamburger button is visible, and clicking it
reveals the nav links.

- [ ] **Step 5: Verify FAQ accordions and tel/mailto links via the accessibility snapshot**

Use `mcp__plugin_ecc_playwright__browser_snapshot` and confirm:
- Each FAQ `<details>` has a `summary` reachable as a button/disclosure.
- Links with `tel:19183999423`, `tel:19183999154`, and `mailto:chrvpark@gmail.com` are present.

- [ ] **Step 6: Stop the local server**

```bash
kill %1 2>/dev/null || true
```

- [ ] **Step 7: Final full-repo status check**

```bash
git status --short
find . -maxdepth 1 -not -path './.git' -not -path '.' -not -path './docs' | sort
```

Expected: `git status --short` shows a clean tree (everything committed), and the file listing
shows exactly: `DEPLOY.md`, `ASSUMPTIONS.md`, `css`, `img`, `index.html`, `js`, `robots.txt`,
`scripts`, `sitemap.xml`.

---

## Self-Review Notes

- **Spec coverage:** every required-work item from the design spec is covered — trust/consistency
  fixes (Task 5, Global Constraints), structured data (Task 5 Step 1 JSON-LD), on-page SEO (Task 5),
  modernization/performance/a11y (Tasks 2–5), deliverables (Tasks 7–8).
- **Type/name consistency:** `#nav-toggle`/`#primary-nav`/`#year` IDs used identically across
  Task 3 (CSS selectors), Task 4 (JS `getElementById` calls), and Task 5 (HTML markup). Image
  filenames (`image0`…`image4`, `-800`/`-1600` suffixes) used identically across Tasks 2 and 5.
- **No placeholders:** every step above contains complete, real file content — no `TBD`/`TODO`
  markers remain except the intentionally-flagged, data-missing items (real dollar rates) called
  out explicitly in `ASSUMPTIONS.md` and `DEPLOY.md` as owner follow-ups, per the brief's own
  instruction to placeholder only genuinely unknown facts rather than invent them.
