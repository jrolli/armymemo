// Minimal pandoc template that renders Markdown through `memo` in lib.typ.
//
// Use pandoc.sh instead of invoking pandoc directly — it supplies the
// $armymemo-root$ metadata and typst root this template needs so it works
// regardless of the caller's working directory:
//
//   ./pandoc.sh memo.md memo.pdf
//
// The Markdown file's YAML front matter supplies the memo metadata; the
// body becomes the numbered paragraphs. See examples/pandoc_example.md.

#import "@local/armymemo:0.1.0": memo

#show: memo.with(
  office-symbol: "$office-symbol$",
$if(date)$
  date: "$date$",
$endif$
$if(suspense)$
  suspense: "$suspense$",
$endif$
  subject: "$subject$",
  organization: (
    name: "$organization.name$",
$if(organization.street)$
    street: "$organization.street$",
$endif$
$if(organization.city-state-zip)$
    city-state-zip: "$organization.city-state-zip$",
$endif$
  ),
  author: (
    name: "$author.name$",
    rank: "$author.rank$",
    branch: "$author.branch$",
$if(author.title)$
    title: "$author.title$",
$endif$
  ),
$if(memo-for)$
  memo-for: (
$for(memo-for)$
    (
      name: "$memo-for.name$",
$if(memo-for.street)$
      street: "$memo-for.street$",
$endif$
$if(memo-for.city-state-zip)$
      city-state-zip: "$memo-for.city-state-zip$",
$endif$
    ),
$endfor$
  ),
$endif$
$if(memo-thru)$
  memo-thru: (
$for(memo-thru)$
    (
      name: "$memo-thru.name$",
$if(memo-thru.street)$
      street: "$memo-thru.street$",
$endif$
$if(memo-thru.city-state-zip)$
      city-state-zip: "$memo-thru.city-state-zip$",
$endif$
    ),
$endfor$
  ),
$endif$
$if(authority)$
  authority: "$authority$",
$endif$
$if(enclosures)$
  enclosures: ($for(enclosures)$"$enclosures$",$endfor$),
$endif$
$if(distribution)$
  distribution: ($for(distribution)$"$distribution$",$endfor$),
$endif$
$if(cf)$
  cf: ($for(cf)$"$cf$",$endfor$),
$endif$
)

$body$
