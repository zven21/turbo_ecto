defmodule Turbo.Ecto.Builder.Join do
  @moduledoc false

  alias Ecto.Query.Builder.Join

  @doc """
  Builds a quoted join expression.

  ## Example

      iex> query = Turbo.Ecto.Variant
      iex> relations = [:product, :prototypes]
      iex> Turbo.Ecto.Builder.Join.build(query, relations)
      #Ecto.Query<from v in Turbo.Ecto.Variant, join: p0 in assoc(v, :product), join: p1 in assoc(v, :prototypes)>

  """
  @spec build(Macro.t(), [Macro.t()]) :: Macro.t()
  def build(query, relations) do
    relations |> Enum.reduce(query, &apply_join(&1, &2))
  end

  @spec apply_join(Macro.t(), Ecto.Queryable.t()) :: Ecto.Query.t() :: no_return()
  def apply_join(relation, query) do
    query
    |> Macro.escape()
    |> Join.build(
      :inner,
      [{:query, [], Elixir}],
      expr(relation),
      nil,
      nil,
      nil,
      nil,
      nil,
      __ENV__
    )
    |> elem(0)
    |> Code.eval_quoted()
    |> elem(0)
  end

  defp expr(relation) do
    quote do
      unquote(Macro.var(relation, Elixir)) in assoc(query, unquote(relation))
    end
  end
end
