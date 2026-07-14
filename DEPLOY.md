# Deploying Country Horizon RV Park

This is a fully static site — `index.html`, `css/`, `js/`, `img/`, `robots.txt`,
`sitemap.xml` at the repo root. No build step, no server, no database.

`css/style.css` is the source of truth for styles, but its full contents are
also inlined verbatim into a `<style>` block in `index.html`'s `<head>` to
avoid a render-blocking stylesheet request. Because there's no build step,
any edit to `css/style.css` must be manually copy-pasted into that `<style>`
block to keep the two in sync.

## Deploy: Cloudflare Pages (recommended — DNS for this domain is already on Cloudflare)

`countryhorizonrvpark.com` is already an active zone in the same Cloudflare
account this repo should deploy to, which makes Cloudflare Pages the
lowest-friction choice: no external DNS changes needed to attach the real
domain later.

1. In the Cloudflare dashboard: **Workers & Pages → Create → Pages → Connect
   to Git**, and select the `kolbeypruitt/chrv` GitHub repository (same flow
   already used for the `kolbeypruitt-com` project on this account).
2. Build settings: **Framework preset** = None, **Build command** = *(leave
   empty)*, **Build output directory** = `/` (repo root). No environment
   variables needed.
3. **Production branch** = `master`. Every push to `master` will auto-deploy
   from that point on; every PR gets its own preview URL automatically.
4. After the first deploy succeeds, go to the project's **Custom domains**
   tab and add `countryhorizonrvpark.com` (and `www.countryhorizonrvpark.com`
   if you want the `www` form to also resolve). Because the zone is already
   on Cloudflare, this is a one-click add — no manual DNS record editing.

This step requires a Cloudflare-account write action (creating the Pages
project) that has to be done from an authenticated Cloudflare dashboard
session — it could not be completed via API in this session (read-only
access only), so it's the one manual step left for the site owner.

## Other deploy options

- **Netlify / Vercel (static)**: connect the repo, leave the build command
  empty, set the publish directory to `/` (repo root).
- **GitHub Pages**: Settings → Pages → Source = a branch (e.g. `master`) /
  root. Simpler but no built-in PR preview URLs, and the real domain would
  need a `CNAME` file plus DNS records pointed at GitHub Pages instead.
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
