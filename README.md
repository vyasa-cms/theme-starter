# Theme starter

A working Vyasa theme, and the path from "I changed a colour" to "it is
in the marketplace". Press **Use this template** on GitHub, clone your
copy, and work through the sections in order; each one leaves you with a
theme that installs.

A Vyasa theme is **data, never code**: a set of design tokens, a layout
tree, and (optionally) templates that run in a sandbox. That is why a
theme can never read your database or run on your server — and why the
whole thing is a folder of JSON and text:

```text
theme/
├── manifest.toml      # name, version, author, required_api = 1
├── tokens.json        # colours (light + dark), type, spacing, layout widths
├── layout.json        # which blocks go where, per template
├── templates/
│   └── single.tera    # optional: a sandboxed override of the post page
└── assets/
    ├── theme.css      # optional: anything the tokens cannot say
    └── images/        # optional, served at /theme-assets/images/…
```

## 1. Run Vyasa locally

```bash
mkdir vyasa && cd vyasa
curl -fsSLO https://raw.githubusercontent.com/vyasa-cms/vyasa/main/docker-compose.yml
docker compose run --rm app migrate
docker compose up -d
docker compose exec app cat .run/setup-token
```

Open <http://localhost:3000/admin/setup>, paste the token and create the
first administrator. You also need the `vyasa` command on your machine
for packing; the installer puts it on your `PATH`:

```bash
curl -fsSL https://vyasa.site/install.sh | sh
```

## 2. Change the look

Open `theme/tokens.json`. Every colour has a light and a dark value:

```json
"primary": { "light": "#8a3324", "dark": "#e0876f" }
```

Change `primary`, pick a heading face (`"heading": "serif"` or
`"system_ui"`, `"mono"`, or `{"custom": "Fraunces"}` with a font face in
`font_faces`), then pack and install:

```bash
scripts/pack.sh                 # writes dist/my-theme-1.vytheme
```

In the admin, **Appearance → Upload**, choose the file, then **Activate**.
Open the site. Every colour, size and spacing on the page came from that
one file; the CSS was compiled for you, with the dark scheme included.

A typo is a hard error, not a silent default: `"primary_colour"` fails
the pack with the unknown key named. That is deliberate — a theme that
packs installs everywhere.

## 3. Change the structure

`theme/layout.json` lists the blocks each template shows, in order:
`index` (the front page), `single` (a post), `page`, `archive`. Move
`"sidebar"` above `"posts"` in `index`, or remove the sidebar entirely
and set `"sidebar_width_px": 0` in the tokens' `layout` section. Pack,
upload — the version in `manifest.toml` must go up each time
(`version = 2`), because an installed version never changes.

The reference for every token and block is
[docs/THEMES.md](https://github.com/vyasa-cms/vyasa/blob/main/docs/THEMES.md).

## 4. Override a template

`theme/templates/single.tera` replaces the post page. Templates are
[Tera](https://keats.github.io/tera/) run in a sandbox: they see the
post, the site and the rendered regions, and nothing else. Add a line
under the title:

```tera
<p class="meta">Filed under {{ post.type }}</p>
```

Server-rendered HTML arrives sanitised and is printed with `| safe`
(`{{ regions.content | safe }}`); everything you add yourself is escaped
by default.

## 5. Add a script — and why it must be signed

Drop a file at `theme/assets/theme.js` and it is served from the site's
own origin and loaded on every page. Because it runs in every visitor's
browser, Vyasa will not install a theme with a script unless it is
**signed** by a key the site trusts. Mint a key once:

```bash
vyasa plugin keygen        # prints a secret and a public key; keep the secret
```

Tell your local install to trust the public key — add
`VYASA_PACKAGE_TRUSTED_KEYS=<public hex>` to the app's environment in
`docker-compose.yml` and restart — then pack with the secret:

```bash
VYASA_SIGNING_KEY=<secret hex> scripts/pack.sh
# dist/my-theme-3.vytheme and dist/my-theme-3.vytheme.sig
```

Upload both at once: select the `.vytheme` and its `.sig` together in the
**Upload package** file picker.
A theme without a script needs none of this.

## 6. Publish

When it looks right, rename it (`name` in `manifest.toml` — lowercase,
digits and dashes), set `author`, and follow
[docs/PUBLISHING.md](https://github.com/vyasa-cms/vyasa/blob/main/docs/PUBLISHING.md):
your public key goes in the listing, the maintainers sign the package
with the marketplace key, and every Vyasa install can then find it under
Appearance → Browse themes.

## Checks

`scripts/pack.sh` validates as it packs, with the same parser the server
uses at install; the GitHub workflow in this repository runs it on every
push. The pack needs the `vyasa` binary (0.1.0 or later).

## Licence

MIT or Apache-2.0, at your option. Your theme can use any licence you like.
