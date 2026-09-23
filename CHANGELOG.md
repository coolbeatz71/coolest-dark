# CHANGELOG

## 0.1.65 | September 22, 2026

Coolest Dark was written for Dart and Flutter. Everything else fell through to a
handful of generic rules, so most languages came out looking washed out, or in a
few cases almost monochrome. This release widens the theme to 35 languages and 35
frameworks, and adds the grammar work needed to make that possible.

### Coverage beyond Dart

Three rules had been narrowed to Dart only (`support.class`, `keyword.declaration`
and `storage.type.annotation`). They are generic again, so classes, declaration
keywords and annotations are coloured everywhere. Import and package keywords now
have rules for Java, Groovy, JS/TS, Python, PHP, C# and CSS at rules.

### Consistent palette across languages

Java, Rust, Go, Scala, Clojure, Julia, Ruby, Kotlin, Swift and Python were compared
role by role against the Dart and C# baseline, then aligned:

* method and function names read the same in every language
* `class`, `struct`, `interface`, `enum`, `record`, `fun`, `func` and `defrecord`
  share one declaration colour
* annotations, attributes and decorators share one colour, from `@Override` to
  `#[derive]` to `^:const`
* imports, namespaces, constants and enum members each got a consistent colour

### Grammar injections

Many languages give a token no scope at all, or reuse one scope for two very
different things, which puts the result out of reach of any theme rule. Twenty two
injections under `syntaxes/` fill those gaps. Some examples:

* Dart marks the outer type and its type arguments identically, so
  `CommandHandler<Command, Result>` was one flat colour
* SwiftUI gives `VStack` and the label `alignment:` the same scope
* PowerShell has no rule for `enum` whatsoever, so the whole block was plain text
* Python returns `title = models.CharField(...)` as a single unscoped token
* Go leaves package qualifiers, member access and struct keys unscoped
* SQL leaves table names after `FROM` and `JOIN` unscoped

### Comments

Comment prose moved from `#707C74` to `#555f5f`. Markup nested inside doc comments
(XML docs, JSDoc, Javadoc, PHPDoc, dartdoc) is blended 20% toward the background,
so a documentation block no longer outshines the code beneath it. The same tokens
keep full strength outside comments.

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

## 0.0.1 | January 16, 2021

- Update the tab and activity foreground colors [#14](https://github.com/coolbeatz71/coolest-dark/pull/14)
