defmodule Turbo.Ecto.Builder.OrderBy do
  @moduledoc false

  alias Ecto.Query.Builder.OrderBy

  @doc """
  Builds a quoted order_by expression.
  """
  @spec build(Macro.t(), [Macro.t()], [Macro.t()]) :: Macro.t()
  def build(query, sorts, binding) do
    query
    |> Macro.escape()
    |> OrderBy.build(binding, Enum.map(sorts, &expr/1), __ENV__)
    |> Code.eval_quoted()
    |> elem(0)
  end

  # [
  #   asc: {:field, [], [{:query, [], Elixir}, :updated_at]},
  #   desc: {:field, [], [{:query, [], Elixir}, :inserted_at]}
  # ]
  defp expr(%{direction: direction, attribute: %{name: name, parent: parent}}) do
    parent = Macro.var(parent, Elixir)
    quote do: {unquote(direction), field(unquote(parent), unquote(name))}
  end
end
