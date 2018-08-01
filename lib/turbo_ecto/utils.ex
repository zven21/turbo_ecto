defmodule Turbo.Ecto.Utils do
  @moduledoc """
  Turbo Utils Set.
  """

  @doc """
  Returns queryable schema.

  ## Example

      iex> Turbo.Ecto.Utils.schema_from_query(Turbo.Ecto.Product)
      Turbo.Ecto.Product

  """
  @spec schema_from_query(Ecto.Query.t()) :: Ecto.Query.t()
  def schema_from_query(queryable) do
    case queryable do
      %{from: %{query: subquery}} -> schema_from_query(subquery)
      %{from: {_, schema}} -> schema
      _ -> queryable
    end
  end
end