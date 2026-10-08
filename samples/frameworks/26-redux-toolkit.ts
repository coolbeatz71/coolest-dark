import { createAsyncThunk, createSelector, createSlice, type PayloadAction } from "@reduxjs/toolkit";
import { configureStore } from "@reduxjs/toolkit";

/**
 * Redux Toolkit framework tour.
 *
 * Covers slices, reducers, async thunks, selectors, entity state,
 * middleware, typed hooks and store configuration.
 */

export interface Article {
  id: string;
  title: string;
  likeCount: number;
  severity: "debug" | "info" | "warning" | "error";
}

interface ArticlesState {
  items: Record<string, Article>;
  ids: string[];
  status: "idle" | "loading" | "succeeded" | "failed";
  error: string | null;
}

const initialState: ArticlesState = { items: {}, ids: [], status: "idle", error: null };

/**
 * Loads articles from the API.
 *
 * @throws when the response is not ok
 */
export const fetchArticles = createAsyncThunk<Article[], { limit?: number }, { rejectValue: string }>(
  "articles/fetchAll",
  async ({ limit = 20 }, { rejectWithValue, signal }) => {
    const res = await fetch(`/api/articles?limit=${limit}`, { signal });
    if (!res.ok) return rejectWithValue(`HTTP ${res.status}`); // inline comment
    return (await res.json()) as Article[];
  },
);

const articlesSlice = createSlice({
  name: "articles",
  initialState,
  reducers: {
    liked(state, action: PayloadAction<string>) {
      const article = state.items[action.payload];
      if (article) article.likeCount += 1; // Immer lets us "mutate"
    },
    removed(state, action: PayloadAction<string>) {
      delete state.items[action.payload];
      state.ids = state.ids.filter((id) => id !== action.payload);
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchArticles.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(fetchArticles.fulfilled, (state, action) => {
        state.status = "succeeded";
        for (const article of action.payload) {
          state.items[article.id] = article;
        }
        state.ids = action.payload.map(({ id }) => id);
      })
      .addCase(fetchArticles.rejected, (state, action) => {
        state.status = "failed";
        state.error = action.payload ?? action.error.message ?? "unknown";
      });
  },
});

export const { liked, removed } = articlesSlice.actions;

export const store = configureStore({
  reducer: { articles: articlesSlice.reducer },
  middleware: (getDefault) => getDefault({ serializableCheck: false }),
  devTools: process.env.NODE_ENV !== "production",
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

const selectArticlesState = (state: RootState) => state.articles;

export const selectAllArticles = createSelector(
  [selectArticlesState],
  ({ items, ids }) => ids.map((id) => items[id]).filter(Boolean),
);

export const selectSevere = createSelector([selectAllArticles], (articles) =>
  articles.filter((a) => a.severity === "error" || a.severity === "warning"),
);
