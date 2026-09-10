# Dawit Sileshi — personal portfolio

Single-page portfolio site. Static HTML, CSS and a little inline JS. No frameworks,
no build step, no dependencies — open `index.html` in a browser and it runs.

## Files

```
index.html      Everything: markup, theme script, scroll-reveal script
styles.css      All styling; light/dark are CSS custom properties
images/         Portrait, favicon, social card
screenshots/    Project screenshots
netlify.toml    Deploy config (publish root, cache + security headers)
```

## The portrait

`images/portrait.jpg` is a 4:5 crop at 600×750, rendered at 132px wide on mobile and
190px on desktop. It sits below the name while narrow and moves into a right-hand column
at 60em.

To swap it, crop to **4:5** and export around 600px wide — that covers 2× displays at the
size it is shown. If you use a different aspect ratio, either update the `aspect-ratio` in
`.portrait` or let `object-fit: cover` crop it, steering the framing with `object-position`
(currently `50% 12%`, which favours the top of the frame where a head usually sits).

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
