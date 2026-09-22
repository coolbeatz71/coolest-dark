import React, { useCallback, useEffect, useMemo, useReducer, useRef } from "react";

/**
 * React framework tour.
 *
 * Covers function components, hooks, context, refs, memoisation,
 * generics in props, event handlers and conditional rendering.
 *
 * @typeParam T - the row type rendered by the list
 */

export interface Article {
  readonly id: string;
  title: string;
  slug: string;
  likeCount: number;
  commentCount: number;
  author?: { displayName: string };
}

interface Props<T extends { id: string }> {
  items: readonly T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  onSelect?: (id: string) => void;
}

type State = { selected: string | null; loading: boolean };
type Action = { type: "select"; id: string } | { type: "loading"; value: boolean };

const ArticleContext = React.createContext<Article | null>(null);

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case "select":
      return { ...state, selected: action.id }; // inline comment
    case "loading":
      return { ...state, loading: action.value };
  }
}

/** A generic, memoised list component. */
export function DataList<T extends { id: string }>({ items, renderItem, onSelect }: Props<T>) {
  const [state, dispatch] = useReducer(reducer, { selected: null, loading: false });
  const listRef = useRef<HTMLUListElement>(null);

  const visible = useMemo(() => items.slice(0, 50), [items]);

  const handleClick = useCallback(
    (id: string) => () => {
      dispatch({ type: "select", id });
      onSelect?.(id);
    },
    [onSelect],
  );

  useEffect(() => {
    listRef.current?.focus();
    return () => dispatch({ type: "loading", value: false });
  }, [visible.length]);

  if (state.loading) return <Spinner size="sm" />;

  return (
    <ul ref={listRef} className="data-list" aria-busy={state.loading}>
      {visible.map((item, index) => (
        <li
          key={item.id}
          className={item.id === state.selected ? "is-selected" : undefined}
          onClick={handleClick(item.id)}
        >
          {renderItem(item, index)}
        </li>
      ))}
      {visible.length === 0 && <li className="empty">Nothing to show</li>}
    </ul>
  );
}

export function ArticleCard({ article }: { article: Article }): JSX.Element {
  return (
    <ArticleContext.Provider value={article}>
      <article className="card" data-id={article.id}>
        <h2>{article.title}</h2>
        <ArticleCardEngagement
          articleId={article.id}
          slug={article.slug}
          likeCount={article.likeCount}
          commentCount={article.commentCount}
        />
        <footer>{article.author?.displayName ?? "Anonymous"}</footer>
      </article>
    </ArticleContext.Provider>
  );
}

declare function Spinner(props: { size: "sm" | "lg" }): JSX.Element;
declare function ArticleCardEngagement(props: Record<string, unknown>): JSX.Element;
