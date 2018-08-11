defmodule Turbo.Ecto.Services.BuildSearchQuery do
  @moduledoc """
  This is learn from
  https://raw.githubusercontent.com/aditya7iyengar/rummage_ecto/master/lib/rummage_ecto/services/build_search_query.ex

  `Turbo.Ecto.Services.BuildSearchQuery` is a service module which serves the search hook.

  `@search_types` is a collection of all the 8 valid `search_types` that come shipped with
  `Turbo.Ecto`'s default search hook. The types are:

  * `eq`: equal. (SQL: `col = 'value'`)
  * `not_eq`: not equal. (SQL: col != 'value')
  * `lt`: less than. (SQL: col < 1024)
  * `lteq`: less than or equal. (SQL: col <= 1024)
  * `gt`: greater than. (SQL: col > 1024)
  * `gteq`: greater than or equal. (SQL: col >= 1024)
  * `present`: not null and not empty. (SQL: col is not null AND col != '')
  * `blank`: is null or empty. (SQL: col is null OR col = '')
  * `is_null`: is null or not null (SQL: col is null)
  * `like`: contains trem value. (SQL: col like "%value%")
  * `not_like`: not contains value. (SQL: col not like '%value%')
  * `ilike`: contains value in a case insensitive fashion. (SQL: )
  * `not_ilike`: not contains value in a case insensitive fashion. (SQL:
  * `in` contains. (SQL: col in ('1024', '1025'))
  * `not_in` not contains. (SQL: col not in ('1024', '1025'))
  * `start_with` start with. (SQL: col like 'value%')
  * `not_start_with` not start with. (SQL: col not like 'value%')
  * `end_with` end with. (SQL: col like '%value')
  * `not_end_with` (SQL: col not like '%value')
  * `is_true` is true. (SQL: col is true)
  * `between`: between begin and end. (SQL: begin <= col <= end)
  """

  import Ecto.Query

  @type search_expr :: :where | :or_where
  @type search_type :: :eq | :not_eq | :gt
                  | :lt | :gteq | :lteq | :is_null | :in | :not_in
                  | :present | :blank | :like | :not_like | :ilike | :not_ilike
                  | :start_with | :end_with | :true | :false | :between

  @search_types ~w(like ilike eq gt lt gteq lteq)a
  @search_exprs ~w(where or_where)a

  @doc """
  """
  @spec run(Ecto.Query.t(), atom(), {__MODULE__.search_expr(), __MODULE__.search_type()}, any()) :: {Ecto.Query.t()}
  def run(queryable, field, {search_expr, search_type}, search_term) when search_type in @search_types and search_expr in @search_exprs do
    apply(__MODULE__, String.to_atom("handle_" <> to_string(search_type)),
          [queryable, field, search_term, search_expr])
  end

  def run(_, _, search_tuple, _) do
    raise "Unknown {search_expr, search_type}, #{inspect search_tuple}\n" <>
      "search_type should be one of #{inspect @search_types}\n" <>
      "search_expr should be one of #{inspect @search_exprs}"
  end

  def search_types, do: @search_types
  def search_exprs, do: @search_exprs


  @doc """
  Builds a searched `queryable` on top of the given `queryable` using
  `field`, `search_term` and `search_expr` when the `search_type` is `like`.

  Checkout [Ecto.Query.API.like/2](https://hexdocs.pm/ecto/Ecto.Query.API.html#like/2)
  for more info.

  NOTE: Be careful of [Like Injections](https://githubengineering.com/like-injection/)

  Assumes that `search_expr` is in #{inspect @search_exprs}.

  ## Examples

  When `search_expr` is `:where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_like(queryable, :field_1, "field_!", :where)
      #Ecto.Query<from p in "parents", where: like(p.field_1, ^"%field_!%")>

  When `search_expr` is `:or_where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_like(queryable, :field_1, "field_!", :or_where)
      #Ecto.Query<from p in "parents", or_where: like(p.field_1, ^"%field_!%")>

  """
  @spec handle_like(Ecto.Query.t(), atom(), String.t(), __MODULE__.search_expr()) :: Ecto.Query.t()
  def handle_like(queryable, field, search_term, :where) do
    queryable
    |> where([..., b],
      like(field(b, ^field), ^"%#{String.replace(search_term, "%", "\\%")}%"))
  end
  def handle_like(queryable, field, search_term, :or_where) do
    queryable
    |> or_where([..., b],
      like(field(b, ^field), ^"%#{String.replace(search_term, "%", "\\%")}%"))
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using
    `field`, `search_term` and `search_expr` when the `search_type` is `ilike`.

    Checkout [Ecto.Query.API.ilike/2](https://hexdocs.pm/ecto/Ecto.Query.API.html#ilike/2)
    for more info.

    Assumes that `search_expr` is in #{inspect @search_exprs}.

    ## Examples

    When `search_expr` is `:where`

        iex> alias Turbo.Ecto.Services.BuildSearchQuery
        iex> import Ecto.Query
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> BuildSearchQuery.handle_ilike(queryable, :field_1, "field_!", :where)
        #Ecto.Query<from p in "parents", where: ilike(p.field_1, ^"%field_!%")>

    When `search_expr` is `:or_where`

        iex> alias Turbo.Ecto.Services.BuildSearchQuery
        iex> import Ecto.Query
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> BuildSearchQuery.handle_ilike(queryable, :field_1, "field_!", :or_where)
        #Ecto.Query<from p in "parents", or_where: ilike(p.field_1, ^"%field_!%")>

  """
  @spec handle_ilike(Ecto.Query.t(), atom(), String.t(),
                    __MODULE__.search_expr()) :: Ecto.Query.t()
  def handle_ilike(queryable, field, search_term, :where) do
    queryable
    |> where([..., b],
      ilike(field(b, ^field), ^"%#{String.replace(search_term, "%", "\\%")}%"))
  end
  def handle_ilike(queryable, field, search_term, :or_where) do
    queryable
    |> or_where([..., b],
      ilike(field(b, ^field), ^"%#{String.replace(search_term, "%", "\\%")}%"))
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using
  `field`, `search_term` and `search_expr` when the `search_type` is `eq`.

  Assumes that `search_expr` is in #{inspect @search_exprs}.

  ## Examples

  When `search_expr` is `:where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_eq(queryable, :field_1, "field_!", :where)
      #Ecto.Query<from p in "parents", where: p.field_1 == ^"field_!">

  When `search_expr` is `:or_where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_eq(queryable, :field_1, "field_!", :or_where)
      #Ecto.Query<from p in "parents", or_where: p.field_1 == ^"field_!">

  """
  @spec handle_eq(Ecto.Query.t(), atom(), term(),
                  __MODULE__.search_expr()) :: Ecto.Query.t()
  def handle_eq(queryable, field, search_term, :where) do
    queryable
    |> where([..., b],
      field(b, ^field) == ^search_term)
  end
  def handle_eq(queryable, field, search_term, :or_where) do
    queryable
    |> or_where([..., b],
      field(b, ^field) == ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using
  `field`, `search_term` and `search_expr` when the `search_type` is `gt`.

  Assumes that `search_expr` is in #{inspect @search_exprs}.

  ## Examples

  When `search_expr` is `:where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_gt(queryable, :field_1, "field_!", :where)
      #Ecto.Query<from p in "parents", where: p.field_1 > ^"field_!">

  When `search_expr` is `:or_where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_gt(queryable, :field_1, "field_!", :or_where)
      #Ecto.Query<from p in "parents", or_where: p.field_1 > ^"field_!">

  """
  @spec handle_gt(Ecto.Query.t(), atom(), term(),
                  __MODULE__.search_expr()) :: Ecto.Query.t()
  def handle_gt(queryable, field, search_term, :where) do
    queryable
    |> where([..., b],
      field(b, ^field) > ^search_term)
  end
  def handle_gt(queryable, field, search_term, :or_where) do
    queryable
    |> or_where([..., b],
      field(b, ^field) > ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using
  `field`, `search_term` and `search_expr` when the `search_type` is `lt`.

  Assumes that `search_expr` is in #{inspect @search_exprs}.

  ## Examples

  When `search_expr` is `:where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_lt(queryable, :field_1, "field_!", :where)
      #Ecto.Query<from p in "parents", where: p.field_1 < ^"field_!">

  When `search_expr` is `:or_where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_lt(queryable, :field_1, "field_!", :or_where)
      #Ecto.Query<from p in "parents", or_where: p.field_1 < ^"field_!">

  """
  @spec handle_lt(Ecto.Query.t(), atom(), term(),
                  __MODULE__.search_expr()) :: Ecto.Query.t()
  def handle_lt(queryable, field, search_term, :where) do
    queryable
    |> where([..., b],
      field(b, ^field) < ^search_term)
  end
  def handle_lt(queryable, field, search_term, :or_where) do
    queryable
    |> or_where([..., b],
      field(b, ^field) < ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using
  `field`, `search_term` and `search_expr` when the `search_type` is `gteq`.

  Assumes that `search_expr` is in #{inspect @search_exprs}.

  ## Examples

  When `search_expr` is `:where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_gteq(queryable, :field_1, "field_!", :where)
      #Ecto.Query<from p in "parents", where: p.field_1 >= ^"field_!">

  When `search_expr` is `:or_where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_gteq(queryable, :field_1, "field_!", :or_where)
      #Ecto.Query<from p in "parents", or_where: p.field_1 >= ^"field_!">

  """
  @spec handle_gteq(Ecto.Query.t(), atom(), term(), __MODULE__.search_expr()) :: Ecto.Query.t()
  def handle_gteq(queryable, field, search_term, :where) do
    queryable
    |> where([..., b],
      field(b, ^field) >= ^search_term)
  end
  def handle_gteq(queryable, field, search_term, :or_where) do
    queryable
    |> or_where([..., b],
      field(b, ^field) >= ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using
  `field`, `search_term` and `search_expr` when the `search_type` is `lteq`.

  Assumes that `search_expr` is in #{inspect @search_exprs}.

  ## Examples

  When `search_expr` is `:where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_lteq(queryable, :field_1, "field_!", :where)
      #Ecto.Query<from p in "parents", where: p.field_1 <= ^"field_!">

  When `search_expr` is `:or_where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_lteq(queryable, :field_1, "field_!", :or_where)
      #Ecto.Query<from p in "parents", or_where: p.field_1 <= ^"field_!">

  """
  @spec handle_lteq(Ecto.Query.t(), atom(), term(), __MODULE__.search_expr()) :: Ecto.Query.t()
  def handle_lteq(queryable, field, search_term, :where) do
    queryable
    |> where([..., b],
      field(b, ^field) <= ^search_term)
  end
  def handle_lteq(queryable, field, search_term, :or_where) do
    queryable
    |> or_where([..., b],
      field(b, ^field) <= ^search_term)
  end

  @doc """
  Builds a searched `queryable` on `field` is_nil (when `term` is true),
  or not is_nil (when `term` is false), based on `search_expr` given.

  Checkout [Ecto.Query.API.like/2](https://hexdocs.pm/ecto/Ecto.Query.API.html#is_nil/1)
  for more info.

  Assumes that `search_expr` is in #{inspect @search_exprs}.

  ## Examples

  When `search_expr` is `:where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_is_null(queryable, :field_1, true, :where)
      #Ecto.Query<from p in "parents", where: is_nil(p.field_1)>
      iex> BuildSearchQuery.handle_is_null(queryable, :field_1, false, :where)
      #Ecto.Query<from p in "parents", where: not(is_nil(p.field_1))>

  When `search_expr` is `:or_where`

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_is_null(queryable, :field_1, true, :or_where)
      #Ecto.Query<from p in "parents", or_where: is_nil(p.field_1)>
      iex> BuildSearchQuery.handle_is_null(queryable, :field_1, false, :or_where)
      #Ecto.Query<from p in "parents", or_where: not(is_nil(p.field_1))>

  """
  @spec handle_is_null(Ecto.Query.t(), atom(), boolean(), __MODULE__.search_expr()) :: Ecto.Query.t()
  def handle_is_null(queryable, field, true, :where) do
    queryable
    |> where([..., b],
      is_nil(field(b, ^field)))
  end
  def handle_is_null(queryable, field, false, :where) do
    queryable
    |> where([..., b],
      not is_nil(field(b, ^field)))
  end
  def handle_is_null(queryable, field, true, :or_where) do
    queryable
    |> or_where([..., b],
      is_nil(field(b, ^field)))
  end
  def handle_is_null(queryable, field, false, :or_where) do
    queryable
    |> or_where([..., b],
      not is_nil(field(b, ^field)))
  end
end
