#import "/lib.typ": memo

#show: memo.with(
  office-symbol: "ATZB-CD-E",
  date: "15 January 2024",
  subject: "Army Memorandum Tutorial and Formatting Guide",
  organization: (
    name: "1st Training Battalion (Example)",
    street: "1234 Army Drive",
    city-state-zip: "Fort Liberty, NC 28310",
  ),
  author: (
    name: "Sarah M. Johnson",
    rank: "CPT",
    branch: "MI",
    title: "Company Commander",
  ),
)

+ *PURPOSE*: This memorandum is a tutorial for using the `armymemo` Typst
  package to create professional military correspondence that is always
  formatted in accordance with AR 25-50.

+ *BACKGROUND*: Traditional word processors often produce formatting
  inconsistencies in military memos. Authoring the memo in Typst separates the
  content from the layout, which the package handles automatically.

+ *BASIC FORMATTING RULES*:

  + Begin each numbered paragraph with a `+`.
  + Create a subparagraph by indenting two spaces before the next `+`.
  + The template assigns the AR 25-50 hierarchy automatically: `1.`, then
    `a.`, then `(1)`, then `(a)`.

+ *TEXT FORMATTING OPTIONS*:

  + *Bold text*: wrap text in single asterisks.
  + _Italic text_: wrap text in underscores.

+ *PARAGRAPH CONTINUATION*: Add another paragraph to the same numbered point by
  leaving a blank line and continuing the indented text, as this paragraph does.

  This second paragraph stays attached to paragraph 5 because it is indented
  under the same list item.

+ *NESTED STRUCTURE EXAMPLE*:

  + This is a first-level subparagraph (renders as "a.").
  + This is another first-level subparagraph (renders as "b.").

    + This is a second-level subparagraph (renders as "(1)").
    + Another second-level subparagraph (renders as "(2)").

      + This is a third-level subparagraph (renders as "(a)").

+ *POINT OF CONTACT*: The point of contact for this memorandum is the
  undersigned at sarah.m.johnson\@army.mil or (910) 555-0123.
