defmodule Turbo.Ecto.Hooks.Paginate do
  @moduledoc """
  Single table Paginate.
  """

  import Ecto.Query

  @per_page 10

  @doc """
  Returns paginate queryable.

  ## Example

      iex> params = %{"per_page" => 5, "page" => 2}
      iex> Turbo.Ecto.Hooks.Paginate.run(Turbo.Ecto.Product, params)
      #Ecto.Query<from p in Turbo.Ecto.Product, limit: ^5, offset: ^5>

  """
  @spec run(Ecto.Query.t(), Map.t()) :: Ecto.Query.t()
  def run(queryable, params) do
    params
    |> format_params()
    |> handle_paginate(queryable)
  end

  defp format_params(params) do
    params
    |> Map.put_new(:per_page, format_integer(Map.get(params, "per_page", @per_page)))
    |> Map.put_new(:page, format_integer(Map.get(params, "page", 1)))
  end

  # build queryable
  defp handle_paginate(formated_params, queryable) do
    per_page = Map.get(formated_params, :per_page)
    page = Map.get(formated_params, :page)

    offset = per_page * (page - 1)

    queryable
    |> limit(^per_page)
    |> offset(^offset)
  end

  # format date, replace string to integer
  defp format_integer(value) do
    if is_integer(value), do: value, else: String.to_integer(value)
  end

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
      |> (&(&1/per_page)).()
      |> Float.ceil()
      |> trunc()

    current_page = Map.get(formated_params, :page)
    next_page = if (total_pages - current_page) >= 1, do: current_page + 1, else: nil
    prev_page = if total_pages >= current_page && current_page > 1, do: current_page - 1, else: nil

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
    |> apply(:all, [distinct(query, :true)])
    |> Enum.count()
  end
end
