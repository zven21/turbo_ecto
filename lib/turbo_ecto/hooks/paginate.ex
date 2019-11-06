defmodule Turbo.Ecto.Hooks.Paginate do
  @moduledoc false

  import Ecto.Query
  alias Turbo.Ecto.Config, as: TConfig
  alias Turbo.Ecto.Hooks.Paginate

  defstruct [:limit, :offset]

  @type t :: %__MODULE__{}
  @per_page TConfig.per_page()

  @doc """
  Returns paginate object.

  ## Example

      iex> params = %{"per_page" => 5, "page" => 2}
      iex> Turbo.Ecto.Hooks.Paginate.run(params)
      {:ok, %Turbo.Ecto.Hooks.Paginate{limit: 5, offset: 5}}

      iex> params = %{}
      iex> Turbo.Ecto.Hooks.Paginate.run(params)
      {:ok, %Turbo.Ecto.Hooks.Paginate{limit: 10, offset: 0}}

  """
  @spec run(map()) :: {:ok, t()}
  def run(params) do
    params
    |> format_params()
    |> handle_paginate()
  end

  defp format_params(params) do
    params
    |> Map.put_new(:per_page, format_integer(Map.get(params, "per_page", @per_page)))
    |> Map.put_new(:page, format_integer(Map.get(params, "page", 1)))
  end

  # build queryable
  defp handle_paginate(formated_params) do
    per_page = Map.get(formated_params, :per_page)
    page = Map.get(formated_params, :page)

    offset = per_page * (page - 1)

    {:ok, %Paginate{limit: per_page, offset: offset}}
  end

  # format date, replace string to integer
  defp format_integer(value) do
    if is_integer(value), do: value, else: String.to_integer(value)
  end

  @doc """
  Returns the paginate info.
  """
  @spec get_paginate(Ecto.Query.t(), map(), Keyword.t()) :: map()
  def get_paginate(queryable, params, opts) do
    formated_params = format_params(params)

    case Keyword.get(opts, :repo) do
      nil -> raise "Expected key `repo` in `opts`, got #{inspect(opts)}"
      repo -> do_get_paginate(queryable, formated_params, repo)
    end
  end

  def do_get_paginate(queryable, formated_params, repo) do
    per_page = Map.get(formated_params, :per_page)
    total_count = get_total_count(queryable, repo)

    total_pages =
      total_count
      |> (&(&1 / per_page)).()
      |> Float.ceil()
      |> trunc()

    current_page = Map.get(formated_params, :page)
    next_page = if total_pages - current_page >= 1, do: current_page + 1, else: nil

    prev_page =
      if total_pages >= current_page && current_page > 1, do: current_page - 1, else: nil

    %{
      current_page: current_page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      next_page: next_page,
      prev_page: prev_page
    }
  end

  defp get_total_count(queryable, repo) do
    queryable
    |> exclude(:select)
    |> exclude(:preload)
    |> exclude(:order_by)
    |> exclude(:limit)
    |> exclude(:offset)
    |> get_count(repo)
  end

  defp get_count(query, repo) do
    repo
    |> apply(:aggregate, [query, :count, :id])
  end
end
