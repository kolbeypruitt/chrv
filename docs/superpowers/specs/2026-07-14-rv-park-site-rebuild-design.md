# Country Horizon RV Park — Static Site Rebuild

Status: Approved. Date: 2026-07-14.

## Background

The repo at the start of this work contained no real site content: `public/index.html`
was a 2014 Themeforest agency template ("FLAT ASPHALT" by Carino Technologies) with
lorem ipsum copy, fake team/testimonials/pricing, and a map centered on San Francisco.
The only RV-park-specific content was the `<title>` tag and one meta description line.
`package.json` names the project `express-angular-template`; `app.js`/`routes/`/`bin/`
are a vestigial Express+Jade scaffold that just serves `public/index.html` for every
route, plus an unrelated leftover AngularJS "guitars" demo (`index cp.html`, `partials/`).

The real site content lives at the live production site, `https://countryhorizonrvpark.com/`,
which is NOT reflected in this repo. All real facts (NAP, rules topics, amenities,
image assets, social links) were pulled from that live site directly (fetched + the
Cloudflare-obfuscated email decoded) rather than invented, since incorrect data would
recreate the exact NAP-consistency problem this rebuild exists to fix.

## Verified facts (source: live site + user)

- Name: **Country Horizon RV Park**
- Address: **9212 W Main St, Ripley, OK 74062** (matches live site exactly)
- Phone: **918-399-9423** (Sholie) — primary/canonical. 918-399-9154 (Jeff) — secondary,
  contact page only.
- Email: **chrvpark@gmail.com** — decoded from the live site's Cloudflare email-obfuscation
  markup (`/cdn-cgi/l/email-protection`); matches the `twitter.com/chrvpark` handle.
- Hours: **6:00 AM – 10:00 PM CST, daily** (from user; live site lists no hours at all,
  which the user's brief identifies as a likely contributor to Google marking the
  business "permanently closed").
- Geo: 35.98640, -96.90234 (from user brief).
- Real logo + 5 real park photos downloaded from `https://countryhorizonrvpark.com/img/`
  (`chrv_logo.svg`, `park/image0.jpg`–`image4.jpg`, sizes 811×458 to 1600×898).
- Live site's actual dead/wrong links confirmed: Google+ → `plus.google.com/+countryhorizonhomesrvparkripley`
  (dead since 2019); old Facebook → `facebook.com/Country-Horizon-RV-Park-near-Cushing-841093472604169/`;
  footer copyright → "© Country Horizon Homes 2016".
- Live site's park rules and amenities text confirmed to contain the exact typos named
  in the user's brief ("Quite Hours", "Accomadations", "distinguish" for "extinguish",
  "damage cause by them").

## Decisions made with the user

1. **Photos**: use the real photos/logo pulled from the live site (downloaded and
   verified accessible), not placeholders or generated stock images.
2. **Rules/amenities copy**: draft fresh from scratch (same 9 rule topics, proofread,
   honest tone) rather than reusing the live site's exact wording verbatim.
3. **Hours**: real hours provided by user — 6 AM–10 PM CST daily — no placeholder needed.
4. **Repo structure**: replace the Express/Jade/Node scaffold entirely with a flat
   static site at repo root. Delete `app.js`, `routes/`, `bin/`, `node_modules`,
   `package.json`, `views` references, and the AngularJS guitars leftovers.

## Design

### 1. Repo structure

```
/
├── index.html
├── robots.txt
├── sitemap.xml
├── css/style.css
├── js/main.js
├── img/
│   ├── logo.svg
│   ├── park/*.jpg + *.webp (5 real photos, optimized, WebP+JPEG fallback)
│   └── favicon set
├── DEPLOY.md
└── ASSUMPTIONS.md
```

A one-time, dev-only `scripts/optimize-images.mjs` (uses `sharp`) generates resized
WebP + JPEG variants from the downloaded original photos. It is not shipped as part
of the served site; it's a build-time tool documented in DEPLOY.md.

### 2. Content — single page, real facts only

One `index.html` mirroring the live site's proven anchor-section structure (Home /
Amenities / Monthly Sites / Park Rules / Location / FAQ / Contact), rebuilt with:

- Corrected NAP everywhere (footer of the single page, header, and JSON-LD), exactly
  as specified in "Verified facts" above.
- Hours displayed prominently (hero/contact area) and in the footer, plus JSON-LD
  `openingHoursSpecification`.
- Park rules rewritten from scratch covering the same 9 topics, proofread.
- Amenities section covering 30/50 amp hookups, well water, sewer, WiFi, dumpster,
  mailboxes, veteran discount (25% off daily rate), pets on leash.
- New "Location" prose section: 7 miles from Cushing at HWY 33 & 108, minutes from
  Stillwater and Perkins, driving times, framed honestly (park is in Ripley, "near
  Cushing" — never "in Cushing").
- New FAQ section (4–6 Q&As) targeting real search intent (monthly rates, pets,
  50-amp, distance to Cushing, veteran discount).
- Real photos gallery using the 5 downloaded images with descriptive alt text.

### 3. Contact method

The live/legacy site posted a contact form to `contact.php`, which won't run on a
static host. Drop the server-side form; replace with large, prominent `tel:` and
`mailto:` call-to-action buttons (matches the "big tap targets for phone" requirement).
No third-party form service is introduced since none was requested.

### 4. SEO

- JSON-LD `Campground` schema: name, address (PostalAddress), geo (GeoCoordinates),
  telephone, email, url, openingHoursSpecification, priceRange, image, sameAs
  (Facebook), amenityFeature entries, areaServed (Cushing, Stillwater, Perkins,
  Ripley OK).
- Optional `FAQPage` JSON-LD matching the on-page FAQ section.
- No specific dollar rates were given in the brief (only "monthly flat rates" and a
  "25% daily-rate discount"). `priceRange` in the JSON-LD will use a qualitative
  placeholder (`$`) rather than invented numbers; call this out in `ASSUMPTIONS.md`
  and `DEPLOY.md` as an owner TODO to supply real rates.
- `<title>`, meta description, canonical, Open Graph + Twitter card tags.
- One `<h1>` containing "RV Park near Cushing" naturally.
- Descriptive H2s per section matching real search intent.
- `sitemap.xml`, `robots.txt`, consistent canonical origin
  (`https://countryhorizonrvpark.com`, no www/non-www or http/https split).
- Dead Google+ link removed entirely; Facebook updated to
  `https://www.facebook.com/CountryHorizonRVPark/`; footer copyright fixed to
  "© Country Horizon RV Park" + dynamic current year (via a tiny inline script).

### 5. Performance / accessibility

- Inline critical CSS in `<head>`; `css/style.css` for the rest, no render-blocking
  scripts (`js/main.js` deferred).
- `<picture>` WebP + JPEG fallback for all photos, explicit width/height to prevent
  layout shift, lazy-loading (`loading="lazy"`) on below-the-fold images.
- Embedded Google Map iframe on the location/contact section, lazy-loaded.
- Sufficient color contrast, visible focus states, `aria-label`s on nav, alt text on
  every image.
- Mobile-first CSS; big tap targets on phone links.

### 6. Verification (before calling this done)

- JSON-LD validates (parses, matches schema.org `Campground`/`FAQPage` shape).
- Lighthouse/mobile pass — check Core Web Vitals aren't obviously broken (no CLS from
  unsized images, no render-blocking JS).
- All `tel:`/`mailto:` links resolve to the correct verified numbers/email.
- Manual visual check at mobile viewport width.
- No console errors on load.

## Deliverables

- Complete static site at repo root per structure above.
- `DEPLOY.md`: how to deploy to a static host, plus manual owner TODOs (submit
  sitemap to Google Search Console, verify site ownership, double-check hours/NAP
  against the actual Google Business Profile since that wasn't directly accessible
  during this session).
- `ASSUMPTIONS.md`: list of assumptions made (rules copy rewritten vs. reused
  verbatim, email decoded from obfuscated markup, etc.).

## Out of scope

- No CMS, no build framework, no JS framework — plain static HTML/CSS/vanilla JS only.
- No third-party contact-form service.
- No multi-page site — single page matches the live site's existing structure and is
  appropriate for a 9-space business (avoids diluting topical authority across thin
  pages).
