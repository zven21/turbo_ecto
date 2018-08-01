defmodule Turbo.Ecto.Hooks.Search do
  @moduledoc """
  Single Table Search
  """

  alias Turbo.Ecto.Services.BuildSearchQuery
  alias Turbo.Ecto.Utils

  @search_type ~w(like ilike eq gt lt gteq lteq)a

  @doc """
  Builds a search `Ecto.Query.t` on top of a given `Ecto.Query.t` variable
  with given `params`.

  ## Example

  When build params use `:like`

      iex> params = %{"q" => %{"name_like" => "name"}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, ^"%name%")>

  When params include `:ilike`

      iex> params = %{"q" => %{"name_ilike" => "name"}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: ilike(p.name, ^"%name%")>

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
    |> Map.to_list()
    |> Enum.reduce(queryable, &search_queryable(&1, &2))
  end

  # only support where expr.
  defp search_queryable({search_field_and_type, search_term}, queryable) do
    [search_field, search_type] = search_field_and_type |> String.split("_")
    search_field = String.to_atom(search_field)
    search_type = String.to_atom(search_type)

    if search_field in Utils.schema_from_query(queryable).__schema__(:fields) && search_type in @search_type do
      BuildSearchQuery.run(queryable, search_field, {:where, search_type}, search_term)
    else
      queryable
    end
  end
  defp search_queryable(_, queryable), do: queryable
end
