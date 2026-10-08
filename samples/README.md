# Theme test samples

Reference files for checking **Coolest Dark** across languages and frameworks.
Every file is self-contained and deliberately packs in as many distinct token
kinds as the language has, so a single file exercises most theme rules.

Each one includes:

- a **documentation comment** in the language's native style (XML docs, JSDoc,
  Javadoc, KDoc, docstrings, rustdoc, POD, `@moduledoc`, …)
- **inline comments** marked `// inline comment` or equivalent
- types, generics, enums, interfaces, functions, async, errors, collections,
  string interpolation, numbers, booleans and null handling
- a `"<summary>"` string **outside** any comment — it must stay bright; if it
  dims, a comment rule is leaking

## Languages (35)

| # | Language | File | Grammar |
|---|---|---|---|
| 01 | Dart | [01-dart.dart](languages/01-dart.dart) | bundled |
| 02 | C# | [02-csharp.cs](languages/02-csharp.cs) | bundled |
| 03 | Java | [03-java.java](languages/03-java.java) | bundled |
| 04 | Kotlin | [04-kotlin.kt](languages/04-kotlin.kt) | `fwcd.kotlin` |
| 05 | Swift | [05-swift.swift](languages/05-swift.swift) | bundled |
| 06 | Rust | [06-rust.rs](languages/06-rust.rs) | bundled |
| 07 | Go | [07-go.go](languages/07-go.go) | bundled |
| 08 | TypeScript | [08-typescript.ts](languages/08-typescript.ts) | bundled |
| 09 | JavaScript | [09-javascript.js](languages/09-javascript.js) | bundled |
| 10 | Python | [10-python.py](languages/10-python.py) | bundled |
| 11 | Ruby | [11-ruby.rb](languages/11-ruby.rb) | bundled |
| 12 | PHP | [12-php.php](languages/12-php.php) | bundled |
| 13 | C | [13-c.c](languages/13-c.c) | bundled |
| 14 | C++ | [14-cpp.cpp](languages/14-cpp.cpp) | bundled |
| 15 | Objective-C | [15-objective-c.m](languages/15-objective-c.m) | bundled |
| 16 | Groovy | [16-groovy.groovy](languages/16-groovy.groovy) | bundled |
| 17 | Lua | [17-lua.lua](languages/17-lua.lua) | bundled |
| 18 | Perl | [18-perl.pl](languages/18-perl.pl) | bundled |
| 19 | R | [19-r.R](languages/19-r.R) | bundled |
| 20 | Julia | [20-julia.jl](languages/20-julia.jl) | bundled |
| 21 | Clojure | [21-clojure.clj](languages/21-clojure.clj) | bundled |
| 22 | F# | [22-fsharp.fs](languages/22-fsharp.fs) | bundled |
| 23 | Bash | [23-bash.sh](languages/23-bash.sh) | bundled |
| 24 | PowerShell | [24-powershell.ps1](languages/24-powershell.ps1) | bundled |
| 25 | SQL | [25-sql.sql](languages/25-sql.sql) | bundled |
| 26 | HTML | [26-html.html](languages/26-html.html) | bundled |
| 27 | SCSS | [27-css.scss](languages/27-css.scss) | bundled |
| 28 | YAML | [28-yaml.yaml](languages/28-yaml.yaml) | bundled |
| 29 | XML | [29-xml.xml](languages/29-xml.xml) | bundled |
| 30 | Markdown | [30-markdown.md](languages/30-markdown.md) | bundled |
| 31 | Scala | [31-scala.scala](languages/31-scala.scala) | `scala-lang.scala` |
| 32 | Elixir | [32-elixir.ex](languages/32-elixir.ex) | `jakebecker.elixir-ls` |
| 33 | x86-64 Assembly | [33-assembly.asm](languages/33-assembly.asm) | `13xforever.language-x86-64-assembly` |
| 34 | WebAssembly (WAT) | [34-webassembly.wat](languages/34-webassembly.wat) | `dtsvet.vscode-wasm` |
| 35 | Zig | [35-zig.zig](languages/35-zig.zig) | `ziglang.vscode-zig` |

## Frameworks (35)

| # | Framework | File | Language |
|---|---|---|---|
| 01 | React | [01-react.tsx](frameworks/01-react.tsx) | TSX |
| 02 | Next.js | [02-nextjs.tsx](frameworks/02-nextjs.tsx) | TSX |
| 03 | Angular | [03-angular.ts](frameworks/03-angular.ts) | TS |
| 04 | NestJS | [04-nestjs.ts](frameworks/04-nestjs.ts) | TS |
| 05 | Express | [05-express.js](frameworks/05-express.js) | JS |
| 06 | Flutter | [06-flutter.dart](frameworks/06-flutter.dart) | Dart |
| 07 | SwiftUI | [07-swiftui.swift](frameworks/07-swiftui.swift) | Swift |
| 08 | Jetpack Compose | [08-compose.kt](frameworks/08-compose.kt) | Kotlin |
| 09 | Spring Boot | [09-springboot.java](frameworks/09-springboot.java) | Java |
| 10 | ASP.NET Core | [10-aspnetcore.cs](frameworks/10-aspnetcore.cs) | C# |
| 11 | Django | [11-django.py](frameworks/11-django.py) | Python |
| 12 | FastAPI | [12-fastapi.py](frameworks/12-fastapi.py) | Python |
| 13 | Rails | [13-rails.rb](frameworks/13-rails.rb) | Ruby |
| 14 | Laravel | [14-laravel.php](frameworks/14-laravel.php) | PHP |
| 15 | Gin | [15-gin.go](frameworks/15-gin.go) | Go |
| 16 | Actix Web | [16-actix.rs](frameworks/16-actix.rs) | Rust |
| 17 | Vitest / Jest | [17-vitest.ts](frameworks/17-vitest.ts) | TS |
| 18 | Docker Compose | [18-docker-compose.yml](frameworks/18-docker-compose.yml) | YAML |
| 19 | GitHub Actions | [19-github-actions.yml](frameworks/19-github-actions.yml) | YAML |
| 20 | Kubernetes | [20-kubernetes.yaml](frameworks/20-kubernetes.yaml) | YAML |
| 21 | Dockerfile | [21-dockerfile.Dockerfile](frameworks/21-dockerfile.Dockerfile) | Dockerfile |
| 22 | Tailwind CSS | [22-tailwind.html](frameworks/22-tailwind.html) | HTML |
| 23 | pytest | [23-pytest.py](frameworks/23-pytest.py) | Python |
| 24 | Apollo GraphQL | [24-graphql-apollo.ts](frameworks/24-graphql-apollo.ts) | TS |
| 25 | Drizzle ORM | [25-prisma-drizzle.ts](frameworks/25-prisma-drizzle.ts) | TS |
| 26 | Redux Toolkit | [26-redux-toolkit.ts](frameworks/26-redux-toolkit.ts) | TS |
| 27 | Electron | [27-electron.js](frameworks/27-electron.js) | JS |
| 28 | Unity | [28-unity.cs](frameworks/28-unity.cs) | C# |
| 29 | Qt | [29-qt.cpp](frameworks/29-qt.cpp) | C++ |
| 30 | Make | [30-makefile.mk](frameworks/30-makefile.mk) | Makefile |
| 31 | Apache Spark | [31-spark.scala](frameworks/31-spark.scala) | Scala |
| 32 | Phoenix LiveView | [32-phoenix.ex](frameworks/32-phoenix.ex) | Elixir |
| 33 | Bare metal / bootloader | [33-bare-metal.asm](frameworks/33-bare-metal.asm) | x86-64 asm |
| 34 | AssemblyScript | [34-assemblyscript.ts](frameworks/34-assemblyscript.ts) | WebAssembly |
| 35 | Zig build system | [35-zig-build.zig](frameworks/35-zig-build.zig) | Zig |

## Workflow

1. Edit `themes/Coolest Dark-color-theme.json`.
2. Repackage and reinstall, then relaunch VS Code.
3. Open the sample and compare.

To identify the exact scope behind any token, put the cursor on it and run
**Developer: Inspect Editor Tokens and Scopes** from the command palette.

> These files are excluded from the published `.vsix` via `.vscodeignore`.
