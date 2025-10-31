defmodule Turbo.Ecto.Builder.OrderBy do
  @moduledoc false

  alias Ecto.Query

  @doc """
  Builds a quoted order_by expression.
  """
  @spec build(Query.t(), [map()], [term()]) :: Query.t()
  def build(query, sorts, binding) do
    # If all sorts target the root binding, we can use atom fields safely
    if Enum.all?(sorts, fn %{attribute: %{parent: parent}} -> parent == :query end) do
      terms = Enum.map(sorts, fn %{direction: direction, attribute: %{name: name}} -> {direction, name} end)

      quoted = quote do
        import Ecto.Query
        from(unquote(Macro.escape(query)), order_by: ^unquote(terms))
      end

      quoted
      |> Code.eval_quoted([], __ENV__)
      |> elem(0)
    else
    parent_to_index =
      binding
      |> Enum.with_index()
      |> Enum.map(fn
        {{name, _, _}, idx} -> {name, idx}
        {name, idx} when is_atom(name) -> {name, idx}
      end)
      |> Map.new()

      terms = Enum.map(sorts, &expr_with_index(&1, parent_to_index))

      quoted = quote do
        import Ecto.Query
        from(unquote(Macro.escape(query)), order_by: ^unquote(terms))
      end

      quoted
      |> Code.eval_quoted([], __ENV__)
      |> elem(0)
    end
  end

  # [
  #   asc: {:field, [], [{:query, [], Elixir}, :updated_at]},
  #   desc: {:field, [], [{:query, [], Elixir}, :inserted_at]}
  # ]
  defp expr_with_index(%{direction: direction, attribute: %{name: name, parent: parent}}, parent_to_index) do
    idx = Map.fetch!(parent_to_index, parent)
    quote do: {unquote(direction), field(unquote({:& , [], [idx]}), unquote(name))}
  end
end
