defmodule Turbo.Ecto.Hooks.Search do
  @moduledoc """
  Single Table Search
  """

  alias Turbo.Ecto.Services.BuildSearchQuery
  alias Turbo.Ecto.Utils

  @doc """
  Builds a search `Ecto.Query.t` on top of a given `Ecto.Query.t` variable
  with given `params`.

  ## Example

  When build params use `:like`

      iex> params = %{"q" => %{"name_like" => "elixir"}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, ^"%elixir%")>

  When params include `:ilike`

      iex> params = %{"q" => %{"name_ilike" => "elixir"}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: ilike(p.name, ^"%elixir%")>

  When params include `:eq`

      iex> params = %{"q" => %{"price_eq" => 100}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price == ^100>

  When params include `:gt`

      iex> params = %{"q" => %{"price_gt" => 100}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price > ^100>

  When params include `:lt`

      iex> params = %{"q" => %{"price_lt" => 100}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price < ^100>

  When params include `:gteq`

      iex> params = %{"q" => %{"price_gteq" => 100}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price >= ^100>

  When params include `:lteq`

      iex> params = %{"q" => %{"price_lteq" => 100}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: p.price <= ^100>

  """
  @spec run(Ecto.Query.t(), Map.t()) :: Ecto.Query.t()
  def run(queryable, search_params), do: handle_search(queryable, search_params)

  defp handle_search(queryable, search_params) do
    search_params
    |> Map.get("q", %{})
    |> Enum.reduce(%{}, &build_query_map(&1, &2, queryable))
    |> Enum.reduce(queryable, &search_queryable(&1, &2))
  end

  # generate search map() at params.
  # params = %{"q" => %{"name_or_category_name_like" => "elixir"}}
  # Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
  def build_query_map({search_field_and_type, search_term}, search_map, queryable) do
    # FIXME
    search_regex = ~r/([a-z1-9_]+)_(like|ilike|eq|gt|lt|gteq|lteq)$/

    if Regex.match?(search_regex, search_field_and_type) do
      [_, match, search_type] = Regex.run(search_regex, search_field_and_type)

      match
      |> build_and_condition()
      |> Enum.reduce(%{}, &build_or_condition(&1, &2))
      |> Enum.reduce(search_map, &build_assoc_query(&1, &2, search_term, search_type, queryable))
    else
      raise "Pls use valid search expr."
    end
  end

  defp build_assoc_query({search_field, search_expr}, search_map, search_term, search_type, queryable) do
    build_assco(search_field, search_field, search_type, queryable, [], search_map, search_type, search_term, search_expr)
  end

  defp build_assco(search_field, field, search_type, queryable, assoc, search_map, search_type, search_term, search_expr) do
    assoc_tables = Enum.join(Utils.schema_from_query(queryable).__schema__(:associations), "|")
    association_regex = ~r{^(#{assoc_tables})}
    split_regex = ~r/^(#{assoc_tables})_([a-z_]+)/

    cond do
      String.to_atom(search_field) in Utils.schema_from_query(queryable).__schema__(:fields) ->
        Map.put(search_map, field, %{
          search_field: search_field,
          search_term: search_term,
          search_type: search_type,
          search_expr: search_expr,
          assocs: assoc
        })

      Regex.match?(association_regex, search_field) ->
        [_, table, search_field] = Regex.run(split_regex, search_field)
        schema = Utils.schema_from_query(queryable).__schema__(:association, String.to_atom(table)).related
        # FIXME
        assoc = Enum.into(assoc, table)
        build_assco(search_field, field, search_type, schema, assoc, search_map, search_type, search_term, search_expr)

      true -> search_map
    end
  end

  # Build with `and` expr condition
  defp build_and_condition(field) do
    field
    |> String.split(~r{(_and_)})
    |> Enum.reduce(%{}, &(Map.put(&2, &1, "where")))
  end

  # Build with `or` expr cnndition
  defp build_or_condition({search_field, _}, search_ory) do
    [hd | tl] = String.split(search_field, ~r{(_or_)})

    tl
    |> Enum.reduce(search_ory, &(Map.put(&2, &1, "or_where")))
    |> Map.put(hd, "where")
  end

  defp search_queryable({_, map}, queryable) do
    # FIXME
    # assocs = Map.get(map, :assoc)
    search_field = String.to_atom(Map.get(map, :search_field))
    search_type = String.to_atom(Map.get(map, :search_type))
    search_term = Map.get(map, :search_term)
    search_expr = String.to_atom(Map.get(map, :search_expr, :where))
    # FIXME
    BuildSearchQuery.run(queryable, search_field, {search_expr, search_type}, search_term)
  end
  defp search_queryable(_, queryable), do: queryable
end
