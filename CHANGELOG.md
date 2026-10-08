# CHANGELOG

## 1.0.0 | September 22, 2026

Coolest Dark was written for Dart and Flutter. Everything else fell through to a
handful of generic rules, so most languages came out looking washed out, or in a
few cases almost monochrome. This release widens the theme to 35 languages and 35
frameworks, and adds the grammar work needed to make that possible.

### Coverage beyond Dart

Three rules had been narrowed to Dart only (`support.class`, `keyword.declaration`
and `storage.type.annotation`). They are generic again, so classes, declaration
keywords and annotations are colored everywhere. Import and package keywords now
have rules for Java, Groovy, JS/TS, Python, PHP, C# and CSS at rules.

### A consistent palette

Java, Rust, Go, Scala, Clojure, Julia, Ruby, Kotlin, Swift and Python were compared
role by role against the Dart and C# baseline, then aligned. Two roles are now
identical everywhere:

* declaration keywords: `class`, `struct`, `interface`, `enum`, `record`, `fun`,
  `func`, `defrecord`
* annotations, attributes and decorators: `@Override`, `#[derive]`, `@dataclass`,
  `^:const`

Types, functions, imports and namespaces line up across most languages. A few
deliberately still differ: TypeScript colors a bare call and a method call
differently, Rust's `use` keeps the keyword color because its scope is shared with
`pub` and `impl`, and constants vary because no two grammars agree on what one is.

The three competing oranges in the theme (`#E6844F`, `#ec6c45`, `#fb8c00`) were
reduced to one.

### Grammar injections

Many languages give a token no scope at all, or reuse one scope for two very
different things, which puts the result out of reach of any theme rule. Twenty two
injections under `syntaxes/` fill those gaps. Some examples:

* Dart marks the outer type and its type arguments identically, so
  `CommandHandler<Command, Result>` was one flat color
* SwiftUI gives `VStack` and the label `alignment:` the same scope
* PowerShell has no rule for `enum` whatsoever, so the whole block was plain text
* Python returns `title = models.CharField(...)` as a single unscoped token
* Go leaves package qualifiers, member access and struct keys unscoped
* SQL leaves table names after `FROM` and `JOIN` unscoped
* Clojure and Julia leave the name after `defrecord` and `struct` unscoped

### Comments

Comment prose moved from `#707C74` to `#555f5f`. Markup nested inside doc comments
(XML docs, JSDoc, Javadoc, PHPDoc, dartdoc) is blended 20% toward the background,
so a documentation block no longer outshines the code beneath it. The same tokens
keep full strength outside comments.

### Editor chrome

* the file explorer and activity bar sit below the editor instead of level with it
* `dart.closingLabels` is set to 50% alpha, so the `// Widget` labels the Dart
  extension draws at the end of a block stop competing with the code. It previously
  inherited `tab.inactiveForeground`, which is full editor foreground

### Test samples

`samples/` holds 35 language and 35 framework files, each one packing in as many
distinct token kinds as the language has, with native doc comments throughout.
They are excluded from the published package via `.vscodeignore`.

### Fixes

* three trailing commas made the theme file invalid strict JSON
* the minimum VS Code version moved from 1.52.0 to 1.75.0

## 0.0.1 | Dec 19, 2020

- Create the syntax colors for Dart/Flutter support [#1](https://github.com/coolbeatz71/coolest-dark/pull/1)

- Publish the first version [#7](https://github.com/coolbeatz71/coolest-dark/pull/7)

## 0.0.2 | January 16, 2021

- Update the tab and activity foreground colors [#14](https://github.com/coolbeatz71/coolest-dark/pull/14)
