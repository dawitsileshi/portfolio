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

## Before you share the link

Two things still need your input.

**1. Replace the portrait.** `images/portrait.svg` is a placeholder glyph, not a photo.
Drop in a square-cropped photo (600×600 or larger) and point the `src` at it:

```html
<!-- in index.html, in the .identity block -->
<img class="portrait" src="images/portrait.jpg" alt="Dawit Sileshi" width="600" height="600" decoding="async">
```

It renders at 64px on mobile and 76px on desktop, cropped to a circle via `object-fit: cover`.

**2. Set the live URL.** `index.html` contains five instances of `REPLACE-ME.netlify.app`
in the Open Graph / canonical tags. Until they point at the real domain, sharing the link
on LinkedIn or Slack will produce a preview with no image. Find and replace all five:

```bash
grep -c REPLACE-ME index.html   # expect 5, then 0 once fixed
```

`og:image` in particular must be an **absolute** URL — relative paths are ignored by most
link scrapers.

## Deploying to Netlify

The site is plain static files, so either route works.

**Drag and drop** — go to <https://app.netlify.com/drop> and drop this folder in. Fastest
way to get a URL, but you re-upload by hand on every change.

**Connected to git** (recommended) — push this repo to GitHub, then in Netlify:
*Add new site → Import an existing project*, pick the repo, and accept the defaults.
`netlify.toml` already sets publish directory to the repo root and no build command.
Every push then deploys automatically.

Either way, set the site name (or a custom domain) first, then do the `REPLACE-ME` swap
above so the social card resolves.

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
