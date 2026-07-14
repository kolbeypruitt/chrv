# Assumptions made during this rebuild

- **Repo did not contain the real site.** The original repo was a generic 2014
  agency template with lorem ipsum content; none of the RV-park-specific copy,
  photos, or rules text existed in it. All real facts were pulled from the live
  production site (`https://countryhorizonrvpark.com/`) during this session and
  from the business owner directly.
- **Site count** (14 graveled sites) is per the owner's direct correction. The
  live production site and the original planning brief both said "9 sites" —
  the owner confirmed the real number is 14, and every mention on the page
  (hero, amenities, FAQ answer + matching FAQPage schema, meta descriptions)
  was updated to match. This is exactly the kind of stale-fact drift this
  rebuild exists to fix — if the number changes again, grep the repo for
  "14 " to find every spot it needs updating (no single source of truth for
  this figure exists since there's no CMS/build step).
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
  live site's existing structure and appropriate for a 14-space business —
  avoids diluting topical SEO authority across several thin pages.
- **No contact form**: the live site posted a contact form to `contact.php`,
  which can't run on a static host. This rebuild replaces it with direct
  `tel:`/`mailto:` call-to-action buttons instead of adding a third-party form
  service that wasn't requested.
