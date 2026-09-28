#import "@local/wiauxb-theme:0.1.0": *

#show: wiauxb-theme.with(
  // dark: true,
  accent: "blue",                // any Catppuccin color name, or omit for auto
  secondary: "maroon",
  config-info(
    title: [The wiauxb Typst theme],
    subtitle: [A Touying port of the Beamer theme],
    author: [Bastien Wiaux],
    date: datetime.today().display(),
    // logo: image("hexrays-dark.svg"),
    logo: logos(
      image("images/uclouvain-light.svg", height: 1em),
      image("images/hexrays.svg", height: 1em),
    )
  ),
)

#title-slide()

= Basics

== Text and lists
#subtitle[the recolored "quirks"]

This is normal body text. Here is *bold (accent)*, _italic (accent)_, and
`inline code` (chip). You can also #alert[alert] something or
#strike[strike it out]. Icons too: #nerd[\u{f015}] #nerd(color: blue)[\u{f0e7}].

- accent bullet one
- accent bullet two
  - a sub-item
- accent bullet three

+ first
+ second

== Blocks

#block-(title: "A plain block")[
  The default block: subtle tint, accent border and title bar, drop shadow.
]

#alert-block(title: "Alert")[Something important and filled.]

#example-block(title: "Example")[An illustrative example, in green.]

//== behold
#focus-slide(subtitle: [a smaller line below])[Behold !]

== Theorem & code

#theorem-block(title: "Theorem 1")[A theorem-like box, in the ternary color.]

#quote(block: true, attribution: [Ada Lovelace])[
  The Analytical Engine has no pretensions whatever to originate anything.
]

#code-block(title: "demo.rs", lang: "rust")[
```rust
fn main() {
    let xs = vec![1, 2, 3];
    println!("{:?}", xs.iter().sum::<i32>());
}
```
]

== Figures
A framed figure (white card, outline, drop shadow):

#framed-image(image("images/hexrays.svg", height: 5cm))

== Theorem & code 2

#code-block(title: [], lang: "rust")[
```rust
fn main() {
    let xs = vec![1, 2, 3];
    println!("{:?}", xs.iter().sum::<i32>());
}
```
]

== inline code

`c x = 1;`

`c main("a", b, 1);`

Highlighted inline (triple backticks, one line): ```rust let x = 1```

Or via the raw function: #raw("let x = 1", lang: "rust")

Highlighted raw block (triple backticks, multiple lines):
```rust
let x = 1
func a(a){
f
}
```

== images
// #set align(center)

#image("images/uclouvain600-light.svg")
#framed-image(image("images/uclouvain600-light.svg"))

== Code from a file
#codefile(read("snippets/example.py"), name: "example.py")

== Accordion
#accordion-block(title: "Always open")[Visible right away.]

#accordion-block(title: "Click to reveal", reveal: "2-")[
  Collapsed on subslide 1, expands from subslide 2 (chevron flips).
]

= Timelines

== Horizontal (discrete)
#htimeline(("Explore", "Design", "Build", "Ship"), active: auto)

== Horizontal (date axis)
#only("1")[
  #htimeline-dates(((2020, "v1"), (2023, "v2"), (2026, "v3")), from: 2019, to: 2027, active: 2)
]
#only("2")[
  #htimeline-dates(((2020, "v1"), (2023, "v2"), (2026, "v3")), from: 2019, to: 2027, active: 3)
]

== Vertical (animates with subslides)
#vtimeline(active: auto,
  (title: "Define", desc: "scope and requirements", icon: "\u{f040}"),
  (title: "Build", desc: "implement and iterate", icon: "\u{f0ad}"),
  (title: "Ship", desc: "release", icon: "\u{f0e7}"),
)

= Wrap-up

== Thanks
#subtitle[questions?]

That's the core feature set.

#focus-slide[Any Questions ?]
