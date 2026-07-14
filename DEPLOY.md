# Deploying Country Horizon RV Park

This is a fully static site — `index.html`, `css/`, `js/`, `img/`, `robots.txt`,
`sitemap.xml` at the repo root. No build step, no server, no database.

`css/style.css` is the source of truth for styles, but its full contents are
also inlined verbatim into a `<style>` block in `index.html`'s `<head>` to
avoid a render-blocking stylesheet request. Because there's no build step,
any edit to `css/style.css` must be manually copy-pasted into that `<style>`
block to keep the two in sync.

## Deploy: Cloudflare Pages (live now)

The site is deployed at **https://chrv.pages.dev** via `wrangler pages deploy`
(direct upload — the Pages project `chrv` already exists on the account that
also holds the `countryhorizonrvpark.com` DNS zone). To redeploy manually
after changes:

```bash
mkdir -p /tmp/chrv-deploy-stage
cp index.html robots.txt sitemap.xml /tmp/chrv-deploy-stage/
cp -R css js img /tmp/chrv-deploy-stage/
npx wrangler pages deploy /tmp/chrv-deploy-stage --project-name=chrv --branch=master
```

(requires `npx wrangler login` once per machine)

**One manual step left — connect Git for auto-deploy-on-push:** the `chrv`
project was created via direct upload, not connected to GitHub, because
attaching a GitHub repo requires authorizing Cloudflare's GitHub App
interactively (no API/CLI token can do this on your behalf). To enable it:

1. Cloudflare dashboard → **Workers & Pages → chrv → Settings → Builds →
   Connect to Git** → select `kolbeypruitt/chrv` (same flow already used for
   the `kolbeypruitt-com` project on this account).
2. Build settings: **Framework preset** = None, **Build command** = *(leave
   empty)*, **Build output directory** = `/` (repo root).
3. **Production branch** = `master`. After this, every push to `master`
   auto-deploys and every PR gets its own preview URL — the manual `wrangler`
   command above is no longer needed.

**Custom domain:** once ready to go live at the real domain, go to the
project's **Custom domains** tab and add `countryhorizonrvpark.com` (and
`www.countryhorizonrvpark.com` if desired). Because the zone is already on
this Cloudflare account, this is a one-click add — no external DNS changes.

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
