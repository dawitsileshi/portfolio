# Dawit Sileshi — personal portfolio

Single-page portfolio site. Static HTML, CSS and a little inline JS. No frameworks,
no build step, no dependencies — open `index.html` in a browser and it runs.

## Files

```
index.html      Everything: markup, the three home-page charts, theme + chart script
styles.css      All styling; light/dark are CSS custom properties
data/           Data projects: each has its own page, PDFs and the SQL behind it
images/         Portrait, favicon, social card
screenshots/    Software project screenshots
Dawit_Sileshi_CV.pdf  CV linked from the hero and contact section
netlify.toml    Deploy config (publish root, cache + security headers)
```

## The home-page charts

The waffle, dot plot and ranked columns on the home page are plain HTML, not images, so
their labels stay readable at every width. Their numbers are the published figures from the
two data projects (Global Findex 2025, re-verified against the microdata). If a project's
figures change, update the inline `style` heights/positions and the labels to match.

## The portrait

`images/portrait.jpg` is a square crop at 640×640, shown as a circle in the About
section — 88px across on mobile, 120px on desktop.

To swap it, crop **square** and framed for a circle: head roughly centred with a little
headroom, cropping around the upper chest. Export about 640px, which covers 2× displays at
the size it is shown. Anything not square will be centre-cropped by `object-fit: cover`,
which usually cuts a portrait badly — crop it yourself rather than relying on that.

The full-resolution camera export is git-ignored — see `images/YOAB*.jpg` in `.gitignore`.
It is 3.8 MB and the site never serves it, so it is kept out of the repo deliberately.

## Before you share the link

**The live URL is set to `https://dawitsileshi.netlify.app`.** If you deploy under a
different name or add a custom domain, update all four tags in `<head>` — `canonical`,
`og:url`, `og:image` and `twitter:image`:

```bash
grep -n 'dawitsileshi\.netlify\.app' index.html   # 4 lines
```

`og:image` must stay an **absolute** URL; relative paths are ignored by most link scrapers.
After changing it, re-scrape with the
[LinkedIn Post Inspector](https://www.linkedin.com/post-inspector/) — LinkedIn caches
previews aggressively and will otherwise keep serving the old one.

## Deploying to Netlify

The site is plain static files, so either route works.

**Drag and drop** — go to <https://app.netlify.com/drop> and drop this folder in. Fastest
way to get a URL, but you re-upload by hand on every change.

**Connected to git** (recommended, and how this is set up) — push to GitHub, then in
Netlify: *Add new site → Import an existing project*, pick the repo, accept the defaults.
`netlify.toml` already sets the publish directory to the repo root with no build command.
Every push to `main` then deploys automatically. Only tracked files are published, so
anything in `.gitignore` never reaches the site.

```bash
git remote add origin https://github.com/dawitsileshi/<repo>.git
git push -u origin main
```

Then set the site name under *Site configuration → Change site name* so the domain matches
the social tags above.

## Design notes

- **Theme.** Dark by default, light on toggle. The choice persists in `localStorage`; with
  nothing stored it follows `prefers-color-scheme`. The theme is applied by an inline
  script in `<head>` so there is no flash of the wrong theme before paint.
- **Colour.** Two token sets under `[data-theme="dark"]` / `[data-theme="light"]`. The
  amber accent is deliberately the only chromatic colour and carries links, the project
  index numbers and the role line.
- **Type.** Space Grotesk for display, IBM Plex Sans for body, IBM Plex Mono for the rails
  and labels. Loaded from Google Fonts — the only external request the page makes.
- **Project layout.** Source order is index → content → rail, which is the correct reading
  order on mobile. On wide screens explicit grid placement pulls the rail back into the
  left column. Change one and check the other.
- **Motion.** A single fade-in on scroll, disabled under `prefers-reduced-motion`. The
  `.js` class on `<html>` is what hides elements, and the script that reveals them is
  inline, so content cannot get stranded invisible if an external file fails to load.

## Screenshots

`warka-*`, `sileenat-*` and `haile-*` are real captures of the live sites, downscaled to
1000px and saved as progressive JPEG. `01/02/03-*` are the Danakil captures at 1400px.
Nothing is larger than it needs to be — the widest display slot is about 696px, so 1400px
covers 2× displays with headroom.

If you replace any of them, update the `width` and `height` attributes to the new
intrinsic size. They are not decorative: the browser reserves layout space from that
ratio, and a wrong value makes the page jump as images load.
