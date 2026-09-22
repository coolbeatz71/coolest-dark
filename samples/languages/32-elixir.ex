defmodule LanguageTour do
  @moduledoc """
  Elixir language tour.

  Covers modules, structs, protocols, behaviours, pattern matching,
  guards, pipes, comprehensions, GenServers and error handling.
  """

  @typedoc "Severity levels for a log line."
  @type severity :: :debug | :info | :warning | :error

  @severities %{debug: 1, info: 2, warning: 3, error: 4}

  defmodule LogEntry do
    @moduledoc "An immutable value type."

    @enforce_keys [:message]
    defstruct message: nil, severity: :info, tags: []

    @type t :: %__MODULE__{
            message: String.t(),
            severity: LanguageTour.severity(),
            tags: [String.t()]
          }
  end

  defprotocol Describable do
    @doc "Renders a human readable summary."
    @spec describe(t) :: String.t()
    def describe(value)
  end

  defimpl Describable, for: LogEntry do
    def describe(%LogEntry{message: message, severity: severity, tags: tags}) do
      "[#{severity}] #{message} (#{length(tags)} tags)"
    end
  end

  @doc """
  Builds a log entry.

  ## Parameters
    * `message` - the human readable text
    * `opts` - `:severity` and `:tags`

  ## Examples

      iex> LanguageTour.new("hello", severity: :error)
      %LanguageTour.LogEntry{message: "hello", severity: :error, tags: []}

  Raises `ArgumentError` when the message is blank.
  """
  @spec new(String.t(), keyword()) :: LogEntry.t()
  def new(message, opts \\ []) when is_binary(message) and byte_size(message) > 0 do
    %LogEntry{
      message: message,
      severity: Keyword.get(opts, :severity, :info),
      tags: Keyword.get(opts, :tags, [])  # inline comment
    }
  end

  def new(_message, _opts), do: raise(ArgumentError, "message required")

  @doc "Classifies a count and severity."
  @spec describe(non_neg_integer(), severity()) :: String.t()
  def describe(0, _severity), do: "empty"
  def describe(_count, :error), do: "failing"
  def describe(count, _severity) when count > 100, do: "busy"
  def describe(_count, _severity), do: "ok"

  @doc "Most recent severe messages, via the pipe operator."
  @spec recent([LogEntry.t()], pos_integer()) :: [String.t()]
  def recent(entries, take \\ 5) do
    entries
    |> Enum.filter(&(@severities[&1.severity] >= 3))
    |> Enum.map(& &1.message)
    |> Enum.take(take)
  end

  @doc "Comprehension with a filter and an into option."
  def index(entries) do
    for %LogEntry{message: message} = entry <- entries,
        entry.severity != :debug,
        into: %{},
        do: {message, entry}
  end

  def fetch(store, id) do
    case Map.fetch(store, id) do
      {:ok, entry} -> {:ok, entry}
      :error -> {:error, :not_found}
    end
  end
end

defmodule LanguageTour.Server do
  @moduledoc "A minimal GenServer."
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, %{}, opts)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:find, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end

  @impl true
  def handle_cast({:put, id, entry}, state), do: {:noreply, Map.put(state, id, entry)}
end
