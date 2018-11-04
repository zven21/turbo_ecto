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
    #Ecto.Query<from v in Turbo.Ecto.Variant, join: p in assoc(v, :product), where: like(p.name, \"%elixir%\") or like(v.name, \"%elixir%\"), limit: 10, offset: 0>
    ```

  """

  alias Turbo.Ecto.Config, as: TConfig
  alias Turbo.Ecto.Builder
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
  @spec turbo(Ecto.Query.t(), Map.t(), Keyword.t()) :: Map.t()
  def turbo(queryable, params, opts \\ []) do
    queryable = turboq(queryable, params)

    %{
      datas: handle_query(queryable, opts),
      paginate: get_paginate(queryable, params, opts)
    }
  end

  @doc """
  Returns processed queryable.

  ## Example

      iex> params = %{"q" => %{"name_or_body_like" => "elixir"}, "s" => "updated_at+asc", "per_page" => 5, "page" => 1}
      iex> Turbo.Ecto.turboq(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, \"%elixir%\") or like(p.body, \"%elixir%\"), order_by: [asc: p.updated_at], limit: 5, offset: 0>

  """
  @spec turboq(Ecto.Query.t(), Map.t()) :: Ecto.Query.t()
  def turboq(queryable, params) do
    Builder.run(queryable, params)
  end

  @doc """
  Gets paginate info.

  ## Example

      iex> params = %{"per_page" => 5, "page" => 2}
      iex> Turbo.Ecto.get_paginate(Turbo.Ecto.Product, params)
      %{per_page: 5, current_page: 2, next_page: nil, prev_page: nil, total_count: 0, total_pages: 0}

  """
  @spec get_paginate(Ecto.Query.t(), Map.t(), Keyword.t()) :: Map.t()
  def get_paginate(queryable, params, opts \\ []) do
    build_opts = Keyword.put_new(opts, :repo, TConfig.repo())
    Paginate.get_paginate(queryable, params, build_opts)
  end

  defp handle_query(queryable, opts) do
    build_opts = Keyword.put_new(opts, :repo, TConfig.repo())

    case Keyword.get(build_opts, :repo) do
      nil -> raise "Expected key `repo` in `opts`, got #{inspect(opts)}"
      repo -> apply(repo, :all, [queryable])
    end
  end
end
