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
