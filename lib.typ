// armymemo — Typst package for AR 25-50 Army memorandums.
//
// Import `memo` and apply it to the memo body:
//
//   #import "@preview/armymemo:0.1.0": memo
//   #show: memo.with(office-symbol: "ATZB-CD-E", subject: "...", ...)
//   + First paragraph...
//
// `memo` sets the page, letterhead, routing, subject, and closing blocks, and
// numbers the body's `+` paragraphs in AR 25-50 style. `typst` is the only tool
// required. All measurements are derived from AR 25-50 (Preparing and Managing
// Correspondence, 10 October 2020) and its memorandum figures.

#let layout = (
  page: (left: 72pt, right: 72pt, top: 132pt, bottom: 52pt),
  font-family: "Arial",
  font-size: 12pt,
  leading: 4pt,
  letterhead: (
    logo-dx: 33pt,
    logo-dy: 33pt,
    logo-height: 72pt,
    header-dx: 4pt,
    header-top: 36pt,
    dept-size: 10pt,
    detail-size: 8pt,
    line-gap: 2pt,
    suspense-dx: 72pt,
    suspense-dy: 104pt,
  ),
  heading: (
    gap-after-office: 18pt,
    gap-after-route: 36pt,
  ),
  continuation: (
    office-top: 72pt,
    subject-top: 88pt,
  ),
  route: (
    wrap-spacing: 6pt,
    hanging-indent: 18pt,
    paragraph-gap: 0pt,
    stacked-gap: -12pt,
  ),
  body: (
    paragraph-gap: 18pt,
    label-gap: 0.4em,
  ),
  closing: (
    authority-gap: 12pt,
    sig-gap-no-authority: 58pt,
    sig-gap-authority: 66pt,
    line-gap: 6pt,
    distribution-gap: 12pt,
    cf-gap: 22pt,
  ),
)

// AR 25-50 paragraph numbering label: 1. / a. / (1) / (a), keyed on nesting depth.
#let _para-depth = state("armymemo-para-depth", 0)
#let _army-label(depth, n) = {
  if depth == 1 {
    numbering("1.", n)
  } else if depth == 2 {
    numbering("a.", n)
  } else if depth == 3 {
    "(" + numbering("1", n) + ")"
  } else {
    "(" + numbering("a", n) + ")"
  }
}

// Join the present parts of a recipient (name, street, city/state/ZIP).
#let _recipient-line(recipient) = {
  let parts = (recipient.name,)
  let street = recipient.at("street", default: none)
  if street != none { parts.push(street) }
  let city = recipient.at("city-state-zip", default: none)
  if city != none { parts.push(city) }
  parts.join([, ])
}

// First-page letterhead and any suspense suspense date, drawn in the page
// foreground so the body always starts at the configured top margin.
#let _letterhead(organization, suspense, logo) = {
  let lh = layout.letterhead
  let header-top = lh.header-top
  let detail-top = header-top + lh.dept-size + lh.line-gap
  let detail-step = lh.detail-size + lh.line-gap

  place(top + left, dx: lh.logo-dx, dy: lh.logo-dy, image(logo, height: lh.logo-height))
  place(
    top + center,
    dx: lh.header-dx,
    dy: header-top,
    text(size: lh.dept-size, weight: "bold")[DEPARTMENT OF THE ARMY],
  )
  place(
    top + center,
    dx: lh.header-dx,
    dy: detail-top,
    text(size: lh.detail-size, weight: "bold")[#organization.name],
  )
  place(
    top + center,
    dx: lh.header-dx,
    dy: detail-top + detail-step,
    text(size: lh.detail-size, weight: "bold")[#organization.street],
  )
  place(
    top + center,
    dx: lh.header-dx,
    dy: detail-top + detail-step * 2,
    text(size: lh.detail-size, weight: "bold")[#organization.city-state-zip],
  )
  if suspense != none {
    place(
      top + right,
      dx: -lh.suspense-dx,
      dy: lh.suspense-dy,
      text(weight: "bold")[S: #suspense],
    )
  }
}

// Continuation pages (page 2+) repeat the office symbol and subject.
#let _continuation-header(office-symbol, subject) = {
  let cont = layout.continuation
  // The page foreground is anchored to the paper corner, so shift content in to
  // the left margin and constrain its width to the printable area.
  let margin = layout.page.left
  let printable = 100% - layout.page.left - layout.page.right
  place(top + left, dx: margin, dy: cont.office-top, block(width: printable)[#office-symbol])
  place(top + left, dx: margin, dy: cont.subject-top, block(width: printable)[SUBJECT: #subject])
}

// Office-symbol line with the date flush to the right margin.
#let _opening-block(office-symbol, date) = {
  block(width: 100%)[
    #office-symbol
    #h(1fr)
    #if date != none { date }
  ]
  v(layout.heading.gap-after-office)
}

// A single routing line with an AR-style 0.25" hanging indent for wraps.
#let _route-line(body, gap) = {
  par(hanging-indent: layout.route.hanging-indent)[#body]
  v(gap)
}

// MEMORANDUM FOR / THRU / FOR RECORD routing block.
#let _route-block(memo-for, memo-thru) = {
  let rt = layout.route

  if memo-thru.len() == 0 and memo-for.len() == 0 {
    _route-line([MEMORANDUM FOR RECORD], rt.paragraph-gap)
    return
  }

  if memo-thru.len() == 1 {
    _route-line([MEMORANDUM THRU #_recipient-line(memo-thru.at(0))], rt.paragraph-gap)
  } else if memo-thru.len() > 1 {
    _route-line([MEMORANDUM THRU], rt.paragraph-gap)
    for (index, recipient) in memo-thru.enumerate() {
      let last = index == memo-thru.len() - 1
      let gap = if last and memo-for.len() > 0 { rt.paragraph-gap } else { rt.stacked-gap }
      _route-line([#_recipient-line(recipient)], gap)
    }
  }

  if memo-for.len() == 1 {
    let prefix = if memo-thru.len() > 0 { [FOR ] } else { [MEMORANDUM FOR ] }
    _route-line([#prefix#_recipient-line(memo-for.at(0))], rt.paragraph-gap)
  } else if memo-for.len() > 1 {
    let label = if memo-thru.len() > 0 { [FOR] } else { [MEMORANDUM FOR] }
    _route-line(label, rt.paragraph-gap)
    for (index, recipient) in memo-for.enumerate() {
      let last = index == memo-for.len() - 1
      let gap = if last { rt.paragraph-gap } else { rt.stacked-gap }
      _route-line([#_recipient-line(recipient)], gap)
    }
  }
}

// Left-margin list (enclosures / distribution / CF) with a heading line.
#let _trailing-list(title, entries, top-gap) = {
  if entries.len() == 0 { return }
  v(top-gap)
  block(width: 100%)[#title]
  for entry in entries {
    v(layout.closing.line-gap)
    block(width: 100%)[#entry]
  }
}

// Authority line, signature block, enclosures, distribution, and CF.
#let _closing-block(author, authority, enclosures, distribution, cf) = {
  let cl = layout.closing

  // Enclosure listing: "Encl" for one, "N Encls" plus a numbered list for many.
  let encl-label = if enclosures.len() == 1 {
    [Encl]
  } else if enclosures.len() > 1 {
    [#enclosures.len() Encls]
  } else {
    none
  }
  let encl-entries = if enclosures.len() <= 1 {
    enclosures
  } else {
    enclosures.enumerate().map(((index, value)) => [#(index + 1). #value])
  }

  let signature = {
    upper(author.name)
    linebreak()
    [#author.rank, #author.branch]
    if author.at("title", default: none) != none {
      linebreak()
      author.title
    }
  }

  // Signature block paired with enclosures, plus the distribution and CF lists.
  let signature-and-trailing = [
    #table(
      columns: (1fr, 1fr),
      stroke: none,
      inset: 0pt,
      column-gutter: 0pt,
      [
        #if encl-label != none {
          block(width: 100%)[#encl-label]
          for entry in encl-entries {
            v(cl.line-gap)
            block(width: 100%)[#entry]
          }
        }
      ],
      [#align(left)[#signature]],
    )
    #_trailing-list([DISTRIBUTION:], distribution, cl.distribution-gap)
    #_trailing-list([CF:], cf, cl.cf-gap)
  ]

  // AR 25-50: the authority line sits two lines below the body; the signature
  // block begins on the fifth line below the authority line (or below the body
  // when there is no authority line). The closing stays on one page, and the
  // weak leading gap collapses with the body's trailing spacing so the offset
  // is deterministic regardless of body length.
  if authority != none {
    v(cl.authority-gap, weak: true)
    block(breakable: false)[
      #block(width: 100%)[#upper(authority):]
      #v(cl.sig-gap-authority)
      #signature-and-trailing
    ]
  } else {
    v(cl.sig-gap-no-authority, weak: true)
    block(breakable: false)[#signature-and-trailing]
  }
}

// Entry point. Apply it to a memo body with `#show: memo.with(..)`.
#let memo(
  office-symbol: "",
  date: none,
  subject: "",
  suspense: none,
  organization: (name: "", street: "", city-state-zip: ""),
  author: (name: "", rank: "", branch: ""),
  memo-for: (),
  memo-thru: (),
  authority: none,
  enclosures: (),
  distribution: (),
  cf: (),
  logo: "DOD_Seal_BW.png",
  doc,
) = {
  set page(
    paper: "us-letter",
    margin: layout.page,
    header-ascent: 0pt,
    footer-descent: 0pt,
    foreground: context {
      if counter(page).get().first() == 1 {
        _letterhead(organization, suspense, logo)
      } else {
        _continuation-header(office-symbol, subject)
      }
    },
    footer: context {
      if counter(page).get().first() > 1 {
        align(center)[#counter(page).display()]
      }
    },
  )
  set text(font: layout.font-family, size: layout.font-size)
  set par(justify: false, leading: layout.leading, spacing: layout.body.paragraph-gap)

  // Memorandums are plain text; render inline code as ordinary body text.
  show raw: it => text(font: layout.font-family, size: layout.font-size)[#it.text]

  // AR 25-50 numbered paragraphs. Only the FIRST line of a (sub)paragraph is
  // indented to carry its number/letter; every runover line returns all the way
  // to the left margin, regardless of nesting depth. The first-line indent grows
  // one quarter inch per level, and the depth state selects the correct
  // 1. / a. / (1) / (a) label.
  show enum: it => {
    _para-depth.update(d => d + 1)
    context {
      let d = _para-depth.get()
      // AR 25-50: a subparagraph's number is aligned with the start of the
      // first-line text of its parent. The indent of a level is therefore the
      // cumulative width of the ancestor labels plus the number-to-text gap,
      // measured in the body font. The fourth level ((a)) shares the third
      // level's ((1)) indentation rather than indenting again.
      let gap = layout.body.label-gap
      let advance(label) = measure(label).width + measure(box(width: gap)).width
      let level = calc.min(d, 3)
      let indent = if level <= 1 {
        0pt
      } else if level == 2 {
        advance[1.]
      } else {
        advance[1.] + advance[a.]
      }
      for (i, child) in it.children.enumerate() {
        block(
          width: 100%,
          above: if d == 1 and i == 0 { 0pt } else { layout.body.paragraph-gap },
          below: 0pt,
        )[
          #set par(hanging-indent: 0pt, first-line-indent: 0pt)
          #box(width: indent)#_army-label(d, i + 1)#h(gap)#child.body
        ]
      }
    }
    _para-depth.update(d => d - 1)
  }

  _opening-block(office-symbol, date)
  _route-block(memo-for, memo-thru)
  block(width: 100%)[SUBJECT: #subject]
  v(layout.heading.gap-after-route)

  doc

  _closing-block(author, authority, enclosures, distribution, cf)
}
