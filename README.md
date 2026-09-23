# Coolest Dark

A dark theme built for people who work across a lot of languages. It started as a
Dart and Flutter theme based on [One Dark Pro](https://marketplace.visualstudio.com/items?itemName=zhuangtongfa.Material-theme)
and [Bear Theme](https://marketplace.visualstudio.com/items?itemName=dahong.theme-bear),
and now covers 35 languages and 35 frameworks with the same palette applied
consistently across all of them.

Declaration keywords and annotations use the same color in every language that has them. Types, functions and imports line up across most languages too, with a few deliberate exceptions where a grammar makes the distinction impossible or where the language reads better its own way.

## Screenshots

### Overview

![overview](https://github.com/coolbeatz71/coolest-dark/raw/master/img/code-sample.png)

### Flutter and Dart

![flutter](https://github.com/coolbeatz71/coolest-dark/raw/master/img/code-flutter.png)

### Java

![java](https://github.com/coolbeatz71/coolest-dark/raw/master/img/code-java.png)

### C#

![csharp](https://github.com/coolbeatz71/coolest-dark/raw/master/img/code-csharp.png)

### React

![react](https://github.com/coolbeatz71/coolest-dark/raw/master/img/code-react.png)

### HTML

![html](https://github.com/coolbeatz71/coolest-dark/raw/master/img/code-html.png)

### Stylesheets, CSS and SCSS

![css](https://github.com/coolbeatz71/coolest-dark/raw/master/img/code-css.png)

## What makes it different

Most themes stop at coloring the scopes a grammar happens to provide. Many
grammars give a token no scope at all, or reuse one scope for two very different
things, and the result is a language that looks flat no matter which theme you
pick. Coolest Dark ships 22 grammar injections to close those gaps, so things like
Flutter named arguments, SwiftUI modifiers, Go struct keys, SQL table names and
PowerShell enums are actually reachable and colored.

Documentation comments are deliberately pushed back. Prose sits well below the
code, and markup nested inside a doc block (XML docs, JSDoc, Javadoc, PHPDoc,
dartdoc) is blended toward the background so a long comment never shouts louder
than the code under it.

## To install

- Search for "Coolest Dark" in the VS Code marketplace, then set it as your color theme.
- The font in the screenshots is ["Cascadia Code"](https://github.com/microsoft/cascadia-code/releases).

## To contribute

Open an [issue](https://github.com/coolbeatz71/coolest-dark/issues) or a
[pull request](https://github.com/coolbeatz71/coolest-dark).

The `samples/` folder holds 70 reference files, one per language and framework,
each packing in as many distinct token kinds as the language has. They are the
quickest way to see the effect of a change across everything at once.

**Enjoy!**
