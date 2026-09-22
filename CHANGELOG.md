# CHANGELOG

## 0.1.1 | October 4, 2026

- Extend the class, class-declaration and annotation colors beyond Dart to every language in the theme: Java, Groovy, JavaScript, TypeScript, JSX/TSX, Python, PHP, C#, CSS/SCSS/LESS

- Restore the generic `support.class`, `keyword.declaration` and `storage.type.annotation` scopes that earlier commits had narrowed to Dart only

- Add import/package/use keyword coloring for Java, Groovy, JS/TS, Python, PHP, C# and CSS at-rules

- Lower the comment foreground from `#707C74` to `#555f5f`, and Python docstrings to `#586261`, so comment prose sits further back from the code

- Blend markup nested inside doc comments (C#/VB XML docs, JSDoc, Javadoc, PHPDoc, dartdoc) 20% toward the editor background; the same tokens keep full strength outside comments

- Add a TextMate grammar injection for Dart (`syntaxes/dart-generics.injection.json`) that scopes the contents of a type-argument list as `support.class.generic.dart`, so `<ChangePasswordCommand, ChangePasswordResult>` can be coloured independently of the `CommandHandler` that owns it

- Fix three trailing commas that made the theme file invalid strict JSON

- Raise the minimum VS Code version from 1.52.0 to 1.75.0

## 0.0.1 | Dec 19, 2020

- Create the syntax colors for Dart/Flutter support [#1](https://github.com/coolbeatz71/coolest-dark/pull/1)

- Publish the first version [#7](https://github.com/coolbeatz71/coolest-dark/pull/7)

## 0.0.1 | January 16, 2021

- Update the tab and activity foreground colors [#14](https://github.com/coolbeatz71/coolest-dark/pull/14)
