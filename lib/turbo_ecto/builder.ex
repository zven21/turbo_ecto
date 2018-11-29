defmodule Turbo.Ecto.Builder do
  @moduledoc false

  alias Turbo.Ecto.Builder.{Join, Where, OrderBy, LimitOffset}
  alias Turbo.Ecto.Hooks.{Search, Sort, Paginate}

  @doc """
  Builds a search `Ecto.Query.t` on top of a given `Ecto.Query.t` variable
  with given `params`.

  ## Example

  When search_type is `:like`

      iex> params = %{"q" => %{"name_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, \"%elixir%\"), limit: 10, offset: 0>

  When search_type is `:ilike`

      iex> params = %{"q" => %{"name_ilike" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, \"%elixir%\"), limit: 10, offset: 0>

  When search_type is `:eq`

      iex> params = %{"q" => %{"price_eq" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price == ^100, limit: 10, offset: 0>

  When search_type is `:gt`

      iex> params = %{"q" => %{"price_gt" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price > ^100, limit: 10, offset: 0>

  When search_type is `:lt`

      iex> params = %{"q" => %{"price_lt" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price < ^100, limit: 10, offset: 0>

  When search_type is `:gteq`

      iex> params = %{"q" => %{"price_gteq" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price >= ^100, limit: 10, offset: 0>

  When search_type is `:lteq`

      iex> params = %{"q" => %{"price_lteq" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price <= ^100, limit: 10, offset: 0>

  when use `and` symbol condition

      iex> params = %{"q" => %{"name_and_body_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, \"%elixir%\") and like(p.body, \"%elixir%\"), limit: 10, offset: 0>

  when use `or` symbol condition

      iex> params = %{"q" => %{"name_or_body_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, \"%elixir%\") or like(p.body, \"%elixir%\"), limit: 10, offset: 0>

  when use `assoc`

      iex> params = %{"q" => %{"category.name_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, join: c in assoc(p, :category), where: like(c.name, \"%elixir%\"), limit: 10, offset: 0>

  when use `and` && `or` && `assoc` condition

      iex> params = %{"q" => %{"category.name_or_name_and_body_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, join: c in assoc(p, :category), where: like(p.body, \"%elixir%\") or (like(c.name, \"%elixir%\") or like(p.name, \"%elixir%\")), limit: 10, offset: 0>

  """
  @spec run(Ecto.Query.t(), Map.t()) :: Ecto.Query.t()
  def run(queryable, params) do
    schema = extract_schema(queryable)
    params = stringify_keys(params)

    with {:ok, %Search{} = searches} <- Search.run(schema, params),
         {:ok, sorts} <- Sort.run(schema, params),
         {:ok, %Paginate{} = %{limit: limit, offset: offset}} <- Paginate.run(params) do
      relations = build_relations(searches, sorts)
      binding = relations |> build_binding()

      queryable
      |> join(relations)
      |> where(searches, binding)
      |> order_by(sorts, binding)
      |> limit(limit, binding)
      |> offset(offset, binding)
    end
  end

  defp join(query, relations), do: Join.build(query, relations)
  defp where(query, grouping, binding), do: Where.build(query, grouping, binding)

  defp order_by(query, [], _), do: query
  defp order_by(query, sorts, binding), do: OrderBy.build(query, sorts, binding)

  defp limit(query, limit, binding), do: LimitOffset.build(:limit, query, limit, binding)
  defp offset(query, offset, binding), do: LimitOffset.build(:offset, query, offset, binding)

  defp build_binding(relations) do
    relations
    |> List.insert_at(0, :query)
    |> Enum.map(&Macro.var(&1, Elixir))
  end

  defp build_relations(grouping, sorts) do
    sorts_parents = Enum.map(sorts, & &1.attribute.parent)

    grouping
    |> List.wrap()
    |> get_grouping_conditions()
    |> Enum.flat_map(& &1.attributes)
    |> Enum.map(& &1.parent)
    |> Enum.concat(sorts_parents)
    |> Enum.uniq()
    |> List.delete(:query)
  end

  defp get_grouping_conditions(groupings, acc \\ [])

  defp get_grouping_conditions([%Search{conditions: conditions, groupings: []} | t], acc) do
    get_grouping_conditions(t, acc ++ conditions)
  end

  defp get_grouping_conditions([%Search{conditions: conditions, groupings: groupings} | t], acc) do
    get_grouping_conditions(t ++ groupings, acc ++ conditions)
  end

  defp get_grouping_conditions([], acc) do
    acc
  end

  defp extract_schema(%{from: {_, schema}}), do: schema
  defp extract_schema(schema), do: schema

  defp stringify_keys(map = %{}) do
    Enum.into(map, %{}, fn {k, v} -> {to_string(k), stringify_keys(v)} end)
  end

  defp stringify_keys([head | rest]) do
    [stringify_keys(head) | stringify_keys(rest)]
  end

  defp stringify_keys(not_a_map) do
    not_a_map
  end
end
