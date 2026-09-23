defmodule FrameworkTourWeb.ArticleLive.Index do
  @moduledoc """
  Phoenix LiveView framework tour.

  Covers LiveView lifecycle, assigns, streams, event handlers,
  PubSub, HEEx templates, components and form handling.
  """

  use FrameworkTourWeb, :live_view

  alias FrameworkTour.Blog
  alias FrameworkTour.Blog.Article
  alias Phoenix.PubSub

  @topic "articles"

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(FrameworkTour.PubSub, @topic)

    socket =
      socket
      |> assign(:page_title, "Articles")
      |> assign(:filter, :all)
      |> assign(:form, to_form(Blog.change_article(%Article{})))
      |> stream(:articles, Blog.list_articles())  # inline comment

    {:ok, socket, temporary_assigns: [flash_message: nil]}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"severity" => severity}, _uri, socket) do
    {:noreply, assign(socket, :filter, String.to_existing_atom(severity))}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  @impl Phoenix.LiveView
  def handle_event("like", %{"id" => id}, socket) do
    case Blog.increment_likes(id) do
      {:ok, %Article{} = article} ->
        PubSub.broadcast(FrameworkTour.PubSub, @topic, {:updated, article})
        {:noreply, stream_insert(socket, :articles, article)}

      {:error, changeset} ->
        {:noreply, socket |> put_flash(:error, "Could not like") |> assign(form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"article" => params}, socket) do
    changeset =
      %Article{}
      |> Blog.change_article(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl Phoenix.LiveView
  def handle_info({:updated, article}, socket) do
    {:noreply, stream_insert(socket, :articles, article, at: 0)}
  end

  @doc """
  Renders a single article card.

  ## Attributes
    * `:article` - the `%Article{}` struct (required)
    * `:class` - extra CSS classes
  """
  attr :article, Article, required: true
  attr :class, :string, default: nil

  def article_card(assigns) do
    ~H"""
    <article class={["card", @class]} id={"article-#{@article.id}"}>
      <h2 class="card__title"><%= @article.title %></h2>

      <p :if={@article.body} class="card__body">
        <%= truncate(@article.body, 160) %>
      </p>

      <footer class="card__footer">
        <span class={"badge badge--#{@article.severity}"}><%= @article.severity %></span>
        <button phx-click="like" phx-value-id={@article.id} class="btn">
          <%= @article.like_count %> likes
        </button>
      </footer>
    </article>
    """
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <main class="articles">
      <.form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} label="Title" required />
        <.button type="submit">Create</.button>
      </.form>

      <div id="articles" phx-update="stream" class="grid">
        <.article_card :for={{dom_id, article} <- @streams.articles} id={dom_id} article={article} />
      </div>
    </main>
    """
  end

  defp truncate(text, length) when is_binary(text) do
    if String.length(text) > length, do: String.slice(text, 0, length) <> "…", else: text
  end
end
