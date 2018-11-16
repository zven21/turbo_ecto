defmodule Turbo.Ecto.Builder.OrderBy do
  @moduledoc false

  alias Ecto.Query.Builder.OrderBy

  def build(query, sorts, binding) do
    query
    |> Macro.escape()
    |> OrderBy.build(binding, Enum.map(sorts, &expr/1), __ENV__)
    |> Code.eval_quoted()
    |> elem(0)
  end

  @doc """
  [
    asc: {:field, [], [{:query, [], Elixir}, :updated_at]},
    desc: {:field, [], [{:query, [], Elixir}, :inserted_at]}
  ]
  """
  def expr(%{direction: direction, attribute: %{name: name, parent: parent}}) do
    parent = Macro.var(parent, Elixir)
    quote do: {unquote(direction), field(unquote(parent), unquote(name))}
  end
end
