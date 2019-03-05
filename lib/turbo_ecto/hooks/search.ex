defmodule Turbo.Ecto.Hooks.Search do
  @moduledoc """
  This module provides a operations that can add searching functionality to
  a pipeline of `Ecto` queries. This module works by taking fields.

  Inspire from: [ex_sieve](https://github.com/valyukov/ex_sieve/blob/master/lib/ex_sieve/node/grouping.ex)
  """

  import Turbo.Ecto.Utils, only: [done: 1]

  alias Turbo.Ecto.Hooks.Search
  alias Search.Condition

  defstruct conditions: nil, combinator: nil, groupings: []

  @type t :: %__MODULE__{}

  @doc """
  Returns the search object.

  ## Examples

      iex> params = %{"q" => %{"name_or_category_name_like" => "elixir", "price_eq" => 1}, "s" => "updated_at+asc", "per_page" => 5, "page" => 1}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      {:ok,
        %Turbo.Ecto.Hooks.Search{
          combinator: :and,
          conditions: [
            %Turbo.Ecto.Hooks.Search.Condition{
              attributes: [
                %Turbo.Ecto.Hooks.Search.Attribute{name: :name, parent: :query},
                %Turbo.Ecto.Hooks.Search.Attribute{name: :name, parent: :category}
              ],
              combinator: :or,
              search_type: :like,
              values: ["elixir"]
            },
            %Turbo.Ecto.Hooks.Search.Condition{
              attributes: [
                %Turbo.Ecto.Hooks.Search.Attribute{name: :price, parent: :query}
              ],
              combinator: :and,
              search_type: :eq,
              values: [1]
            }
          ],
          groupings: []
        }
      }

      iex> params = %{"filter" => %{"name_like" => "elixir", "price_eq" => 1}}
      iex> Turbo.Ecto.Hooks.Search.run(Turbo.Ecto.Product, params)
      {:ok,
        %Turbo.Ecto.Hooks.Search{
          combinator: :and,
          groupings: [],
          conditions: [%Turbo.Ecto.Hooks.Search.Condition{search_type: :like, values: ["elixir"], attributes: [%Turbo.Ecto.Hooks.Search.Attribute{name: :name, parent: :query}], combinator: :and}, %Turbo.Ecto.Hooks.Search.Condition{attributes: [%Turbo.Ecto.Hooks.Search.Attribute{name: :price, parent: :query}], combinator: :and, search_type: :eq, values: [1]}]}
      }

  """
  @spec run(Ecto.Query.t(), Map.t()) :: any()
  def run(schema, params)

  def run(schema, %{"q" => q}) do
    q
    |> extract(schema)
    |> done()
  end

  def run(schema, %{"filter" => filter}) do
    filter
    |> extract(schema)
    |> done()
  end

  def run(schema, _) do
    %{}
    |> extract(schema)
    |> done()
  end

  defp extract(params, schema), do: do_extract(params, schema)

  defp do_extract(params, schema, combinator \\ :and) do
    case extract_conditions(params, schema) do
      {:error, reason} -> {:error, reason}
      conditions -> %Search{combinator: combinator, conditions: conditions}
    end
  end

  defp extract_condition({key, value}, schema), do: Condition.extract(key, value, schema)

  defp extract_conditions(params, schema) do
    params
    |> Enum.map(&extract_condition(&1, schema))
    |> validate_conditions()
  end

  # validate_conditions
  defp validate_conditions(conditions, acc \\ [])
  defp validate_conditions([{:error, reason} | _tail], _acc), do: {:error, reason}

  defp validate_conditions([attribute | tail], acc),
    do: validate_conditions(tail, acc ++ [attribute])

  defp validate_conditions([], acc), do: acc
end
