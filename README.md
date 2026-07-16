# armymemo

`armymemo` is a [Typst](https://typst.app) package that formats AR 25-50 Army
memorandums. A memo is a plain `.typ` file, and the only tool you need is
`typst`:

```bash
typst compile memo.typ
```

There is no other dependency — no LaTeX, no pandoc, no Python.

## Writing a memo

Import `memo` and apply it to the body with a `show` rule. The metadata —
subject, office symbol, organization, author, routing, enclosures, and so on —
goes in the `memo.with(..)` call; the body is just numbered paragraphs.

```typst
#import "@preview/armymemo:0.1.0": memo

#show: memo.with(
  office-symbol: "ATZB-CD-E",
  date: "15 January 2024",
  subject: "Weekly Training Meeting Minutes",
  organization: (
    name: "1st Training Battalion",
    street: "1234 Army Drive",
    city-state-zip: "Fort Liberty, NC 28310",
  ),
  author: (name: "Sarah M. Johnson", rank: "CPT", branch: "MI", title: "Company Commander"),
)

+ The weekly training meeting was held on 14 January 2024 at 0900.

+ The next meeting is scheduled for 21 January 2024 at 0900.
```

See [`examples/`](examples) for memos covering `MEMORANDUM FOR`, multi-recipient
and `THRU` routing, suspense dates, authority lines, enclosures, distribution,
and CF blocks.

## Installing

- **Typst Universe** (once published): nothing to install — `#import
  "@preview/armymemo:0.1.0": memo"` and `typst` fetches it automatically.
- **Local package**: copy `lib.typ`, `DA_LOGO.png`, and `typst.toml` into
  `{typst-data-dir}/packages/local/armymemo/0.1.0/`, then import
  `@local/armymemo:0.1.0`. The data dir is `~/.local/share/typst` on Linux,
  `~/Library/Application Support/typst` on macOS.
- **Vendored**: drop `lib.typ` and `DA_LOGO.png` next to your memo and import
  `"lib.typ"`.

## Fields

| Field | Required | Notes |
| --- | --- | --- |
| `office-symbol` | yes | Top left, and repeated on continuation pages. |
| `subject` | yes | After the routing block; repeated on continuation pages. |
| `date` | no | `DD Month YYYY`. Flush right on the office-symbol line. |
| `suspense` | no | Printed as `S: <date>` above the office-symbol line. |
| `organization` | yes | Dict: `name`, `street`, `city-state-zip` (letterhead). |
| `author` | yes | Dict: `name`, `rank`, `branch`, and optional `title`. |
| `memo-for` | no | Array of recipient dicts → `MEMORANDUM FOR`. |
| `memo-thru` | no | Array of recipient dicts → `MEMORANDUM THRU`. |
| `authority` | no | Authority line above the signature block (uppercased). |
| `enclosures` | no | Array → `Encl` / `N Encls`. |
| `distribution` | no | Array → `DISTRIBUTION:` block. |
| `cf` | no | Array → `CF:` block. |

If neither `memo-for` nor `memo-thru` is given, the memo is a `MEMORANDUM FOR
RECORD`. A recipient is a dict with `name` and optional `street` /
`city-state-zip`:

```typst
memo-for: (
  (name: "Commander, Alpha Company, 1st Training Battalion", city-state-zip: "Fort Liberty, NC 28310"),
)
```

## Body and paragraph numbering

Write paragraphs as a Typst numbered list with `+`. Nesting is by indentation;
the package assigns the AR 25-50 hierarchy automatically:

```typst
+ First paragraph.

  + Renders as "a."
  + Renders as "b."

    + Renders as "(1)"

      + Renders as "(a)"
```

Runover lines return to the left margin per AR 25-50. Add another paragraph to a
numbered item by leaving a blank line and continuing the indented text. Use
`*bold*` and `_italic_` for inline emphasis.

## Writing a memo in Markdown (optional)

If you'd rather write the body in Markdown, `pandoc.typ` is a template that
wires [pandoc](https://pandoc.org)'s Markdown front matter into `memo.with(..)`.
It's optional — `typst` is still the only tool required for the `.typ`
workflow above.

Put the memo metadata in the file's YAML front matter and the body as an
ordinary Markdown numbered list, then run pandoc with `--pdf-engine=typst`
from the repository root (so `/lib.typ` resolves):

```bash
pandoc examples/pandoc_example.md --template=pandoc.typ --pdf-engine=typst -o memo.pdf
```

See [`examples/pandoc_example.md`](examples/pandoc_example.md) for the front
matter shape; its fields mirror the [Fields](#fields) table above.

## Building the examples

```bash
make          # builds every examples/*.typ to build/*.pdf + build/*.fields.json
```

`make` runs `typst compile --root .` so the in-repo examples can resolve the
package entrypoint (`/lib.typ`) and the seal image from the repository root.

The memo font defaults to Arial and can be overridden at compile time on
hosts that don't have it (use a metrically compatible family such as
Liberation Sans to keep the AR 25-50 layout intact):

```bash
typst compile --input font="Liberation Sans" memo.typ
make TYPST_FLAGS='--input font="Liberation Sans"'
```

`make` applies `TYPST_FLAGS` to the field extraction too, so the emitted
esign positions always match the compiled PDFs.

## Electronic-signature field positions

Every memo emits the positions of its signature and concurrence boxes as
`metadata` elements labeled `<esign-field>`, for downstream tooling (`esign`)
that adds PDF signature form fields. The template emits one `Signature` field
covering the pen-signature space above the typed name, and one `ConcurN` field
per MEMORANDUM THRU addressee line. Extract them as JSON:

```bash
# typst >= 0.15:
typst eval 'query(<esign-field>).map(it => it.value)' --in memo.typ --format json
# typst <= 0.14:
typst query memo.typ "<esign-field>" --field value
```

(`make` writes this to `build/<name>.fields.json` for each example.) Each
entry is `{name, page, x, y, w, h}`: a unique field name, the 1-indexed page,
and the box's top-left corner, width, and height in pt, measured from the
page's top-left corner with y increasing downward.

Custom fields can be added in a memo body with the exported `esign-field`
function — call it inline, immediately before the text it anchors to:

```typst
#import "/lib.typ": memo, esign-field

... #esign-field("Initials", 0.75in, 0.3in, dx: 3in, dy: -0.1in)Anchored line text
```

## Notes

- AR 25-50 (Preparing and Managing Correspondence, 10 October 2020) is the
  normative source for the layout in `lib.typ`.
- Generated PDFs and the `build/` directory stay out of version control.
