---
title: Markdown language tour
severity: info
tags: [docs, reference]
---

# Markdown language tour

Covers headings, emphasis, lists, links, images, code, tables,
blockquotes, footnotes, task lists and HTML passthrough.

## Emphasis

*italic*, _also italic_, **bold**, __also bold__, ***both***,
~~strikethrough~~, `inline code`, and a line break at the end.\
Second line after a hard break.

## Lists

1. Ordered item one
2. Ordered item two
   - Nested unordered
   - Another nested
     1. Deeply nested ordered

- [x] Completed task
- [ ] Outstanding task

## Links and images

[Inline link](https://example.com "With a title")
[Reference link][repo]
<https://example.com/autolink>
![Alt text](./img/icon.png "Screenshot")

[repo]: https://github.com/coolbeatz71/coolest-dark

## Code

Indented block:

    const severity = "error";

Fenced with a language:

```typescript
/** Returns the most severe messages. */
export function recent(entries: LogEntry[], take: number): string[] {
  return entries
    .filter((e) => e.severity === Severity.Error) // inline comment
    .map(({ message }) => message)
    .slice(0, take);
}
```

```sql
SELECT message FROM log_entry WHERE severity_id >= 3 ORDER BY created_at DESC;
```

## Table

| Severity | Rank | Severe |
| :------- | ---: | :----: |
| debug    |    1 |   no   |
| error    |    4 |  yes   |

## Blockquote

> A quote with **emphasis**.
>
> > And a nested quote.

## Footnote

Here is a statement with a footnote.[^1]

[^1]: The footnote body.

## HTML passthrough

<div align="center">
  <strong>Raw HTML</strong> inside Markdown.
</div>

---

Horizontal rule above.
