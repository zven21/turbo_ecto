defmodule Turbo.Ecto.Builder do
  @moduledoc false

  alias Turbo.Ecto.Builder.{Join, Where, OrderBy, LimitOffset}
  alias Turbo.Ecto.Hooks.{Search, Sort, Paginate}
  alias Turbo.Ecto.Utils

  @type queryable :: Ecto.Schema.t() | Ecto.Queryable.t()

  @doc """
  Builds a search `Ecto.Query.t` on top of a given `Ecto.Query.t` variable
  with given `params`.

  ## Example

  When search_type is `:like`

      iex> params = %{"q" => %{"name_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, where: like(p0.name, \"%elixir%\"), limit: 10, offset: 0>

  When search_type is `:ilike`

      iex> params = %{"q" => %{"name_ilike" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, where: ilike(p0.name, \"%elixir%\"), limit: 10, offset: 0>

  When search_type is `:eq`

      iex> params = %{"q" => %{"price_eq" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, where: p0.price == ^100, limit: 10, offset: 0>

  When search_type is `:gt`

      iex> params = %{"q" => %{"price_gt" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, where: p0.price > ^100, limit: 10, offset: 0>

  When search_type is `:lt`

      iex> params = %{"q" => %{"price_lt" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, where: p0.price < ^100, limit: 10, offset: 0>

  When search_type is `:gteq`

      iex> params = %{"q" => %{"price_gteq" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, where: p0.price >= ^100, limit: 10, offset: 0>

  When search_type is `:lteq`

      iex> params = %{"q" => %{"price_lteq" => 100}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, where: p0.price <= ^100, limit: 10, offset: 0>

  when use `and` symbol condition

      iex> params = %{"q" => %{"name_and_body_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, where: like(p0.name, \"%elixir%\") and like(p0.body, \"%elixir%\"), limit: 10, offset: 0>

  when use `or` symbol condition

      iex> params = %{"q" => %{"name_or_body_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, where: like(p0.name, \"%elixir%\") or like(p0.body, \"%elixir%\"), limit: 10, offset: 0>

  when use `assoc`

      iex> params = %{"q" => %{"category_name_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, join: c1 in assoc(p0, :category), where: like(c1.name, \"%elixir%\"), limit: 10, offset: 0>

  when use `and` && `or` && `assoc` condition

      iex> params = %{"q" => %{"category_name_or_name_and_body_like" => "elixir"}}
      iex> Turbo.Ecto.Builder.run(Turbo.Ecto.Schemas.Post, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, join: c1 in assoc(p0, :category), where: like(p0.body, \"%elixir%\") or (like(c1.name, \"%elixir%\") or like(p0.name, \"%elixir%\")), limit: 10, offset: 0>

  """
  @spec run(queryable(), map()) :: Ecto.Query.t()
  def run(queryable, params) do
    schema = extract_schema(queryable)

    # make params is compaction stringify_keys
    params =
      params
      |> Utils.stringify_keys()
      |> Utils.compaction!()

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
    else
      {:error, :attribute_not_found} -> raise "attribute_not_found, got #{inspect(params)}"
      {:error, :search_type_not_found} -> raise "search_type_not_found, got #{inspect(params)}"
      {:error, _} -> raise "Expected `params`, got #{inspect(params)}"
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

  def extract_schema(%{from: %{source: %{query: subquery}}}), do: extract_schema(subquery)
  def extract_schema(%{from: %{source: {_, schema}}}), do: schema
  def extract_schema(schema), do: schema
end
