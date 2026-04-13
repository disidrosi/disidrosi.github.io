# Tobia Cavalli – Personal Website

This repository contains the source code for my personal website, built with
[Hugo](https://gohugo.io/). All layouts, styles, and assets are self-contained
in this repo — no external theme dependency.

You can find my website at 🔗
[https://tobiacavalli.com](https://tobiacavalli.com)

## Content structure

Posts live in `content/essays/` (long-form) and `content/guides/` (how-to). Each
post is a **leaf bundle**: a directory containing `index.md` and any assets it
uses.

```text
content/essays/my-post/
  index.md
  figure-1.png
```

Images placed in the bundle directory are automatically processed, resized, and
converted to WebP at build time. To add a caption, use the markdown title syntax
— the image is wrapped in a `<figure>` with a `<figcaption>`:

```markdown
![Alt text](figure.png "Caption rendered below the image.")
```

SVGs are embedded as-is with their aspect ratio preserved. Raster images
generate a responsive `srcset` at 400, 800, 1200, and 1600 px widths (capped at
the source width).

## Front matter

| Field | Description |
| --- | --- |
| `title` | Page title |
| `date` | Publication date (`YYYY-MM-DD`) |
| `lastmod` | Last modified date (`YYYY-MM-DD`); shown in post meta only when explicitly set |
| `summary` | Short description shown on list pages |
| `description` | Longer description used in SEO meta tags |
| `lead` | Introductory paragraph rendered below the title in lead style; supports Markdown |
| `tags` | Array of tags, e.g. `["materials-science", "history"]` |
| `toc` | `true` to show a collapsible table of contents (default: `true` for essays and guides) |
| `math` | `true` to enable KaTeX rendering on this page |
| `slug` | Custom URL slug, overrides the directory name |
| `aliases` | Array of redirect paths, e.g. `["/old/url/"]` |
| `draft` | `true` to exclude from production builds |

`author` and `hideReply` are set via cascade in the section `_index.md` files
and do not need to be set per post.

## Math

Enable KaTeX on a page with `math: true` in front matter, then use standard
LaTeX delimiters:

| Style | Syntax |
| --- | --- |
| Inline | `\(x^2 + y^2 = r^2\)` |
| Block (LaTeX) | `\[ E = mc^2 \]` |
| Block (dollar) | `$$ E = mc^2 $$` |

## Diagrams

Diagrams are pre-rendered to SVG at author time using
[`mermaid-cli`](https://github.com/mermaid-js/mermaid-cli) — no client-side
JavaScript, no CDN dependency, no runtime cost on the page.

To add a diagram:

1. Write the diagram source as a `.mmd` file next to the post's `index.md`:

   ```text
   content/essays/my-post/
     index.md
     diagram.mmd
   ```

2. Render every `.mmd` under `content/` to a sibling `.svg`:

   ```sh
   npm run render:diagrams
   ```

3. Reference the rendered `.svg` from the post with standard markdown image syntax:

   ```markdown
   ![Diagram alt text](diagram.svg "Caption rendered as a figcaption.")
   ```

Both the `.mmd` source and the generated `.svg` are committed. The `.mmd` files
stay co-located with the post for editability but are excluded from the build
output via `ignoreFiles` in `hugo.toml`.

Diagram styling (fonts, colors, node fills, edge thickness) is configured in
`mermaid-config.json` at the repo root and is keyed to the site's design tokens.
Edit it to restyle every diagram at once, then re-run `npm run render:diagrams`.

## Callouts

Callouts use GitHub-style blockquote alert syntax:

```markdown
> [!note]
> Text of the callout.
```

With a custom title:

```markdown
> [!warning] Watch out
> Something important to flag.
```

As a collapsible `<details>` element, add `+` or `-` after the type:

```markdown
> [!note]+
> Starts expanded; the reader can collapse it.

> [!note]-
> Starts collapsed; the reader can expand it.
```

Available types:

| Color | Types |
| --- | --- |
| Blue | `note`, `info` |
| Green | `tip`, `important` |
| Orange | `warning`, `caution` |
| Red | `danger` |
| Purple | `question` |
| Amber | `example` |
| Gray | `quote` |

## Tags

Add a `tags` array to any post's front matter:

```yaml
tags: ["materials-science", "history-of-science"]
```

Each tag generates an archive page at `/tags/<tag-name>/`.

## Bookshelf

The `/bookshelf` page lists books, papers, and essays organized by theme. Data
is stored in `data/bookshelf/`, with one TOML file per theme. Files are rendered
in alphabetical order, so numeric prefixes control display order.

### Adding a theme

Create a new file, e.g. `data/bookshelf/02_history_of_science.toml`:

```toml
name = "History of Science"

[[sections]]
type = "Books"

  [[sections.entries]]
  ...

[[sections]]
type = "Papers"

  [[sections.entries]]
  ...
```

The `name` field is the heading shown on the page. The `type` field inside each
`[[sections]]` block can be `"Books"`, `"Papers"`, or `"Essays"`.

### Entry fields

| Field | Required | Applies to | Description |
| --- | --- | --- | --- |
| `title` | yes | all | Title of the work |
| `author` | yes | all | Author name(s) |
| `year` | yes | all | Publication year |
| `annotation` | no | all | Short personal note shown below the entry |
| `image` | no | Books | Cover image filename (see below) |
| `essay` | no | Books | Path to a related essay, e.g. `"/essays/review-pieces-of-the-action/"` — renders as a "Related essay" link |
| `journal` | no | Papers | Journal name, shown in the metadata line |
| `doi` | no | Papers | Bare DOI identifier, e.g. `10.1000/xyz123` — renders as a `doi` pill link |

### Book cover images

Cover images go in `assets/images/bookshelf/`. Hugo automatically resizes and
converts them to WebP at build time — place the original file at any resolution.
The suggested naming convention is `{lastname}_{short_title}.jpg`, e.g.
`bush_pieces-of-the-action.jpg`. Reference the filename (not the path) in the
`image` field. If the field is absent or the file is not found, no image is
shown.

### Currently Reading

The file `data/bookshelf/reading.toml` is special: its entries render at the top
of the bookshelf page in a highlighted section. When a book is finished, move
the entry to the appropriate topic file. Unlike topic files, entries are listed
directly under `[[entries]]` (no `[[sections]]` wrapper):

```toml
[[entries]]
title = "Some Book"
author = "Author Name"
year = 2025
image = "author_some-book.jpg"
```

### Example

```toml
name = "Science and Engineering"

[[sections]]
type = "Books"

  [[sections.entries]]
  title = "Pieces of the Action"
  author = "Vannevar Bush"
  year = 2022
  image = "bush_pieces-of-the-action.jpg"
  annotation = "An account of how American science was organized during World War II."
  essay = "/essays/review-pieces-of-the-action/"

[[sections]]
type = "Papers"

  [[sections.entries]]
  title = "Science: The Endless Frontier"
  author = "Vannevar Bush"
  year = 1945
  journal = "Science"
  doi = "10.2307/3224875"
  annotation = "The report that shaped postwar US science policy."
```

## Dependencies

The site has no external runtime dependencies. Fonts are self-hosted
(`static/fonts/`), KaTeX CSS and fonts are self-hosted (`static/katex/`),
diagrams are pre-rendered to SVG, and all layouts and styles live in this repo.
No CDN requests are made at page load.

Build-time dependencies: Hugo (extended edition) and optionally `npm` for
diagram rendering (`mermaid-cli`).

## Contributing

Currently, this repository is not intended for public contributions. However,
feel free to fork the repository and customize it for your own website.
