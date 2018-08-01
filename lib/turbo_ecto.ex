defmodule Turbo.Ecto do
  @moduledoc """
  Elixir Search compoment, support single table search, sort and paginate.
  """

  alias Turbo.Ecto.Hooks.{Paginate, Sort, Search}
  alias Turbo.Ecto.Config, as: TConfig

  @doc """
  Returns a result and pageinate info.

  ## Example

      iex> params = %{"q" => %{"name_like" => "q"}, "s" => "updated_at+asc", "per_page" => 5, "page" => 1}
      iex> Turbo.Ecto.turbo(Turbo.Ecto.Product, params)
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

      iex> params = %{"q" => %{"name_like" => "name", "body_like" => "body"}, "s" => "updated_at+asc", "per_page" => 5, "page" => 1}
      iex> Turbo.Ecto.turboq(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.body, ^"%body%"), where: like(p.name, ^"%name%"), order_by: [asc: p.updated_at], limit: ^5, offset: ^0>

  """
  @spec turboq(Ecto.Query.t(), Map.t()) :: Ecto.Query.t()
  def turboq(queryable, params) do
    [Search, Sort, Paginate]
    |> Enum.reduce(queryable, &run_hook(&1, &2, params))
  end

  @doc """
  Returns searching result.

  ## Example

      iex> params = %{"q" => %{"name_like" => "q"}}
      iex> Turbo.Ecto.search(Turbo.Ecto.Product, params)
      []

  """
  @spec search(Ecto.Query.t(), Map.t(), Keyword.t()) :: any
  def search(queryable, params, opts \\ []) do
    queryable
    |> searchq(params)
    |> handle_query(opts)
  end

  @doc """
  Returns searching queryable.

  ## Example

      iex> Turbo.Ecto.searchq(Turbo.Ecto.Product, %{"q" => %{"name_like" => "q"}})
      #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, ^"%q%")>

  """
  @spec search(Ecto.Query.t(), Map.t()) :: Ecto.Query.t()
  def searchq(queryable, params), do: Search.run(queryable, params)

  @doc """
  Returns sorting result.

  ## Example

      iex> params = %{"s" => "updated_at+desc"}
      iex> Turbo.Ecto.sort(Turbo.Ecto.Product, params)
      []

  """
  @spec sort(Ecto.Query.t(), Map.t(), Keyword.t()) :: any
  def sort(queryable, params, opts \\ []) do
    queryable
    |> sortq(params)
    |> handle_query(opts)
  end

  @doc """
  Returns sorting queryable.

  ## Example

      iex> params = %{"s" => "updated_at+desc"}
      iex> Turbo.Ecto.sortq(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, order_by: [desc: p.updated_at]>

  """
  @spec sortq(Ecto.Query.t(), Map.t()) :: Ecto.Query.t()
  def sortq(queryable, params), do: Sort.run(queryable, params)

  @doc """
  Returns Paginate result.

  ## Example

      iex> params = %{"per_page" => 5, "page" => 2}
      iex> Turbo.Ecto.paginate(Turbo.Ecto.Product, params)
      %{dates: [], paginate: %{current_page: 2, next_page: nil, per_page: 5, prev_page: nil, total_count: 0, total_pages: 0}}

  """
  @spec paginate(Ecto.Query.t(), Map.t(), Keyword.t()) :: Map.t()
  def paginate(queryable, params, opts \\ []) do
    queryable = paginateq(queryable, params)

    %{
      dates: handle_query(queryable, opts),
      paginate: get_paginate(queryable, params, opts)
    }
  end

  @doc """
  Returns Paginate queryable.

  ## Example

      iex> params = %{"per_page" => 5, "page" => 2}
      iex> Turbo.Ecto.paginateq(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, limit: ^5, offset: ^5>

  """
  @spec paginateq(Ecto.Query.t(), Map.t()) :: Ecto.Query.t()
  def paginateq(queryable, params), do: Paginate.run(queryable, params)

  @doc """
  Gets paginate info.

  ## Example

      iex> params = %{"per_page" => 5, "page" => 2}
      iex> Turbo.Ecto.get_paginate(Turbo.Ecto.Product, params)
      %{per_page: 5, current_page: 2, next_page: nil, prev_page: nil, total_count: 0, total_pages: 0}

  """
  # @spec get_paginate(Ecto.Query.t(), Map.t(), Keyword.t()) :: Map.t()
  def get_paginate(queryable, params, opts \\ []) do
    build_opts = Keyword.put_new(opts, :repo, TConfig.repo)
    Paginate.get_paginate(queryable, params, build_opts)
  end

  # Invoke hooks run method.
  defp run_hook(hook, queryable, params), do: apply(hook, :run, [queryable, params])

  defp handle_query(queryable, opts) do
    build_opts = Keyword.put_new(opts, :repo, TConfig.repo)
    case Keyword.get(build_opts, :repo) do
      nil -> raise "Expected key `repo` in `opts`, got #{inspect(opts)}"
      repo -> apply(repo, :all, [queryable])
    end
  end

  defmacro __using__(opts) do
    quote do
      alias Turbo.Ecto.Config, as: TConfig

      @doc """
      Returns result

      ## Example

          iex> params = %{"q" => %{"name_like" => "q"}, "s" => "updated_at+asc", "per_page" => 5, "page" => 1}
          iex> Turbo.Ecto.turbo(Turbo.Ecto.Product, params)
          %{
            paginate: %{current_page: 1, per_page: 5, next_page: nil, prev_page: nil, total_count: 0, total_pages: 0},
            datas: []
          }

      """
      @spec turbo(Ecto.Query.t(), map(), Keyword.t()) :: any()
      def turbo(queryable, params, opts \\ []) do
        Turbo.Ecto.turbo(queryable, params, uniq_merge(opts, defaults()))
      end

      @doc """
      Returns queryable

      ## Example

          iex> Turbo.Ecto.searchq(Turbo.Ecto.Product, %{"q" => %{"name_like" => "q"}})
          #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, ^"%q%")>

      """
      @spec turboq(Ecto.Query.t(), map(), Keyword.t()) :: Ecto.Query.t()
      def turboq(queryable, params, opts \\ []) do
        Turbo.Ecto.turboq(queryable, params)
      end

      @doc """
      Returns search result.

      ## Example

          iex> params = %{"q" => %{"name_like" => "q"}
          iex> Turbo.Ecto.search(Turbo.Ecto.Product, params})
          []

      """
      @spec search(Ecto.Query.t(), map(), Keyword.t()) :: any()
      def search(queryable, params, opts \\ []) do
        Turbo.Ecto.search(queryable, params, uniq_merge(opts, defaults()))
      end

      @doc """
      Returns searching queryable.

      ## Example

          iex> Turbo.Ecto.searchq(Turbo.Ecto.Product, %{"q" => %{"name_like" => "q"}})
          #Ecto.Query<from p in Turbo.Ecto.Product, where: like(p.name, ^"%q%")>

      """
      @spec searchq(Ecto.Query.t(), map(), Keyword.t()) :: Ecto.Query.t()
      def searchq(queryable, params, opts \\ []) do
        Turbo.Ecto.searchq(queryable, params)
      end

      @doc """
      Returns sort data result.

      ## Example

          iex> params = %{"s" => "updated_at+desc"}
          iex> Turbo.Ecto.sort(Turbo.Ecto.Product, params)
          []

      """
      @spec sort(Ecto.Query.t(), map(), Keyword.t()) :: any()
      def sort(queryable, params, opts \\ []) do
        Turbo.Ecto.sort(queryable, params, uniq_merge(opts, defaults()))
      end

      @doc """
      Returns sort queryable.

      ## Example

          iex> params = %{"s" => "updated_at+desc"}
          iex> Turbo.Ecto.sortq(Turbo.Ecto.Product, params)
          #Ecto.Query<from p in Turbo.Ecto.Product, order_by: [desc: p.updated_at]>

      """
      @spec sortq(Ecto.Query.t(), map(), Keyword.t()) :: Ecto.Query.t()
      def sortq(queryable, params, opts \\ []) do
        Turbo.Ecto.sortq(queryable, params)
      end

      @doc """
      Return paginate result.

      ## Example

          iex> params = %{"per_page" => 5, "page" => 2}
          iex> Turbo.Ecto.paginate(Turbo.Ecto.Product, params)
          %{dates: [], paginate: %{current_page: 2, next_page: nil, per_page: 5, prev_page: nil, total_count: 0, total_pages: 0}}

      """
      @spec paginate(Ecto.Query.t(), map(), Keyword.t()) :: any()
      def paginate(queryable, params, opts \\ []) do
        Turbo.Ecto.paginate(queryable, params, uniq_merge(opts, defaults()))
      end

      @doc """
      Return paginate queryable.

      ## Example

          iex> params = %{"per_page" => 5, "page" => 2}
          iex> Turbo.Ecto.paginateq(Turbo.Ecto.Product, params)
          #Ecto.Query<from p in Turbo.Ecto.Product, limit: ^5, offset: ^5>

      """
      @spec paginateq(Ecto.Query.t(), map(), Keyword.t()) :: Ecto.Query.t()
      def paginateq(queryable, params, opts \\ []) do
        Turbo.Ecto.paginateq(queryable, params)
      end

      defp defaults() do
        keys = ~w(repo per_page)a
        Enum.map(keys, &get_defs/1)
      end

      defp get_defs(key) do
        app = Application.get_application(__MODULE__)
        {key, Keyword.get(unquote(opts), key, apply(TConfig, key, [app]))}
      end

      defp uniq_merge(keyword1, keyword2) do
        keyword2
        |> Keyword.merge(keyword1)
        |> Keyword.new()
      end
    end
  end
end
