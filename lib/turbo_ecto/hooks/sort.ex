defmodule Turbo.Ecto.Hooks.Sort do
  @moduledoc """
  Single Table Sort
  """

  import Ecto.Query
  alias Turbo.Ecto.Utils

  @sort_order ~w(asc desc)a

  @doc """
  Returns sort queryable.

  ## Example

      iex> params = %{"s" => "inserted_at+desc"}
      iex> Turbo.Ecto.Hooks.Sort.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, order_by: [desc: p.inserted_at]>

  """
  @spec run(Ecto.Query.t(), Map.t()) :: Ecto.Query.t()
  def run(queryable, params), do: handle_sort(queryable, params)

  defp handle_sort(queryable, sort_params) do
    sort_params
    |> Map.get("s", "")
    |> String.split("+")
    |> build_sort(queryable)
  end

  defp handle_ordering(queryable, field, order) do
    order_by_assoc(queryable, order, field)
  end

  defp order_by_assoc(queryable, order_type, field) do
    order_by(queryable, [p0, ..., p2], [{^order_type, field(p2, ^field)}])
  end

  defp build_sort([field, order] = sort_string, queryable) when length(sort_string) == 2 do
    field = String.to_atom(field)
    order = String.to_atom(order)

    if field in Utils.schema_from_query(queryable).__schema__(:fields) && order in @sort_order do
      handle_ordering(queryable, field, order)
    else
      queryable
    end
  end
  defp build_sort(_, queryable), do: queryable
end
