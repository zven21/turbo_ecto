defmodule Turbo.Ecto do
  @moduledoc """
  A rich ecto component, including search sort and paginate. https://hexdocs.pm/turbo_ecto

  ## Example

  ### Category Table Structure

    |  Field | Type | Comment |
    | ------------- | ------------- | --------- |
    | `name`  | string  |  |

  ### Product Table Structure

    |  Field | Type | Comment |
    | ------------- | ------------- | --------- |
    | `name`  | string  |  |
    | `body` | text |  |
    | `price` | float |  |
    | `category_id` | integer | |
    | `available` | boolean |  |

  ### Variant Table Structure

    |  Field | Type | Comment |
    | ------------- | ------------- | --------- |
    | `name`  | string  |  |
    | `price` | float |  |
    | `product_id` | integer | |

  * Input Search

    ```elixir
    url_query = http://localhost:4000/varinats?q[product_name_or_name_like]=elixir
    ```

  * Expect output:

    ```elixir
    iex> params = %{"q" => %{"product_name_or_name_like" => "elixir"}}
    iex> Turbo.Ecto.turboq(Turbo.Ecto.Variant, params)
    #Ecto.Query<from v0 in Turbo.Ecto.Variant, join: p1 in assoc(v0, :product), where: like(p1.name, \"%elixir%\") or like(v0.name, \"%elixir%\"), limit: 10, offset: 0>
    ```

  """

  alias Turbo.Ecto.Config, as: TConfig
  alias Turbo.Ecto.{Builder, Utils}
  alias Turbo.Ecto.Hooks.Paginate

  @doc """
  Returns a result and pageinate info.

  ## Example

      iex> params = %{"q" => %{"name_or_product_name_like" => "elixir", "price_eq" => "1"}, "s" => "updated_at+asc", "per_page" => 5, "page" => 1}
      iex> Turbo.Ecto.turbo(Turbo.Ecto.Variant, params)
      %{
        paginate: %{current_page: 1, per_page: 5, next_page: nil, prev_page: nil, total_count: 0, total_pages: 0},
        datas: []
      }

  """
  @spec turbo(Ecto.Query.t(), map(), keyword()) :: map()
  def turbo(queryable, params, opts \\ []) do
    build_opts = uniq_merge(opts, TConfig.defaults())

    entry_name = Keyword.get(build_opts, :entry_name)
    paginate_name = Keyword.get(build_opts, :paginate_name)
    prefix = Keyword.get(build_opts, :prefix)

    queryable = queryable |> turboq(params) |> Map.put(:prefix, prefix)

    %{
      entry_name => handle_query(queryable, build_opts),
      paginate_name => get_paginate(queryable, params, build_opts)
    }
    |> Utils.symbolize_keys()
  end

  defp uniq_merge(keyword1, keyword2) do
    keyword2
    |> Keyword.merge(keyword1)
    |> Keyword.new()
  end

  @doc """
  Returns processed queryable.

  ## Example

      iex> params = %{"q" => %{"name_or_body_like" => "elixir", "a_eq" => ""}, "s" => "updated_at+asc", "per_page" => 5, "page" => 1}
      iex> Turbo.Ecto.turboq(Turbo.Ecto.Product, params)
      #Ecto.Query<from p0 in Turbo.Ecto.Product, where: like(p0.name, \"%elixir%\") or like(p0.body, \"%elixir%\"), order_by: [asc: p0.updated_at], limit: 5, offset: 0>

  """
  @spec turboq(Ecto.Query.t(), map()) :: Ecto.Query.t()
  def turboq(queryable, params), do: Builder.run(queryable, params)

  defp get_paginate(queryable, params, opts), do: Paginate.get_paginate(queryable, params, opts)

  defp handle_query(queryable, opts) do
    case Keyword.get(opts, :repo) do
      nil -> raise "Expected key `repo` in `opts`, got #{inspect(opts)}"
      repo -> apply(repo, :all, [queryable])
    end
  end
end
