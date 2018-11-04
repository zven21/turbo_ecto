defmodule Turbo.Ecto.Services.BuildSearchQuery do
  @moduledoc """
  `Turbo.Ecto.Services.BuildSearchQuery` is a service module which serves the search hook.

  `@search_types` is a collection of all the 8 valid `search_types` that come shipped with
  `Turbo.Ecto`'s default search hook. The types are:

  * [x] `eq`: equal. (SQL: `col = 'value'`)
  * [x] `not_eq`: not equal. (SQL: col != 'value')
  * [x] `lt`: less than. (SQL: col < 1024)
  * [x] `lteq`: less than or equal. (SQL: col <= 1024)
  * [x] `gt`: greater than. (SQL: col > 1024)
  * [x] `gteq`: greater than or equal. (SQL: col >= 1024)
  * [x] `is_present`: not null and not empty. (SQL: col is not null AND col != '')
  * [x] `blank`: is null or empty. (SQL: col is null OR col = '')
  * [x] `is_null`: is null or not null (SQL: col is null)
  * [x] `like`: contains trem value. (SQL: col like "%value%")
  * [x] `not_like`: not contains value. (SQL: col not like '%value%')
  * [x] `ilike`: contains value in a case insensitive fashion. (SQL: )
  * [x] `not_ilike`: not contains value in a case insensitive fashion. (SQL:
  * [x] `in` contains. (SQL: col in ('1024', '1025'))
  * [x] `not_in` not contains. (SQL: col not in ('1024', '1025'))
  * [x] `start_with` start with. (SQL: col like 'value%')
  * [x] `not_start_with` not start with. (SQL: col not like 'value%')
  * [x] `end_with` end with. (SQL: col like '%value')
  * [x] `not_end_with` (SQL: col not like '%value')
  * [x] `true` is true. (SQL: col is true)
  * [x] `not_true` is true. (SQL: col is false)
  * [x] `false` is true. (SQL: col is false)
  * [x] `not_false` is true. (SQL: col is true)
  * [ ] `between`: between begin and end. (SQL: begin <= col <= end)
  """

  alias Turbo.Ecto.Hooks.Search.Attribute

  @search_types ~w(eq
                  like
                  not_eq
                  cont
                  not_cont
                  lt
                  lteq
                  gt
                  gteq
                  in
                  not_in
                  matches
                  does_not_match
                  start
                  not_start
                  end
                  not_end
                  true
                  not_true
                  false
                  not_false
                  present
                  blank
                  null
                  not_null)

  @true_values [1, '1', 'T', 't', true, 'true', 'TRUE', "1", "T", "t", "true", "TRUE"]

  def search_types, do: @search_types

  @doc """
  ## Examples

  When `search_type` is `:like`:

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> alias Turbo.Ecto.Hooks.Search.Attribute
      iex> BuildSearchQuery.handle_expr(:like, %Attribute{name: "title", parent: :query}, ["a"])
      {:like, [], [{:field, [], [{:query, [], Elixir}, "title"]}, "%a%"]}

  When `search_type` is `:eq`:

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> alias Turbo.Ecto.Hooks.Search.Attribute
      iex> BuildSearchQuery.handle_expr(:eq, %Attribute{name: "title", parent: :query}, ["a"])
      {:==, [context: Turbo.Ecto.Services.BuildSearchQuery, import: Kernel],
        [{:field, [], [{:query, [], Elixir}, "title"]}, {:^, [], ["a"]}]}

  When `search_type` is `:not_eq`:

      iex> alias Turbo.Ecto.Services.BuildSearchQuery
      iex> alias Turbo.Ecto.Hooks.Search.Attribute
      iex> BuildSearchQuery.handle_expr(:not_eq, %Attribute{name: "title", parent: :query}, ["a"])
      {:!=, [context: Turbo.Ecto.Services.BuildSearchQuery, import: Kernel],
        [{:field, [], [{:query, [], Elixir}, "title"]}, {:^, [], ["a"]}]}

  """

  @spec handle_expr(Atom.t(), %Attribute{}, Keyword.t()) :: Atom.t()
  def handle_expr(:like, attribute, [value | _]) do
    quote do: like(unquote(field_expr(attribute)), unquote("%#{value}%"))
  end

  def handle_expr(:not_like, attribute, [value | _]) do
    quote do: not like(unquote(field_expr(attribute)), unquote("%#{value}%"))
  end

  def handle_expr(:eq, attribute, [value | _]) do
    quote(do: unquote(field_expr(attribute)) == ^unquote(value))
  end

  def handle_expr(:not_eq, attribute, [value | _]) do
    quote do: unquote(field_expr(attribute)) != ^unquote(value)
  end

  def handle_expr(:ilike, attribute, [value | _]) do
    quote do: ilike(unquote(field_expr(attribute)), unquote("%#{value}%"))
  end

  def handle_expr(:not_ilike, attribute, [value | _]) do
    quote do: not ilike(unquote(field_expr(attribute)), unquote("%#{value}%"))
  end

  def handle_expr(:lt, attribute, [value | _]) do
    quote do: unquote(field_expr(attribute)) < ^unquote(value)
  end

  def handle_expr(:lteq, attribute, [value | _]) do
    quote do: unquote(field_expr(attribute)) <= ^unquote(value)
  end

  def handle_expr(:gt, attribute, [value | _]) do
    quote do: unquote(field_expr(attribute)) > ^unquote(value)
  end

  def handle_expr(:gteq, attribute, [value | _]) do
    quote do: unquote(field_expr(attribute)) >= ^unquote(value)
  end

  def handle_expr(:in, attribute, values) do
    quote do: unquote(field_expr(attribute)) in unquote(values)
  end

  def handle_expr(:not_in, attribute, values) do
    quote do: not (unquote(field_expr(attribute)) in unquote(values))
  end

  def handle_expr(:matches, attribute, [value | _]) do
    quote do: ilike(unquote(field_expr(attribute)), unquote(value))
  end

  def handle_expr(:does_not_match, attribute, [value | _]) do
    quote do: not ilike(unquote(field_expr(attribute)), unquote(value))
  end

  def handle_expr(:start_with, attribute, [value | _]) do
    quote do: ilike(unquote(field_expr(attribute)), unquote("#{value}%"))
  end

  def handle_expr(:not_start_with, attribute, [value | _]) do
    quote do: not ilike(unquote(field_expr(attribute)), unquote("#{value}%"))
  end

  def handle_expr(:end_with, attribute, [value | _]) do
    quote do: ilike(unquote(field_expr(attribute)), unquote("%#{value}%"))
  end

  def handle_expr(:not_end_with, attribute, [value | _]) do
    quote do: not ilike(unquote(field_expr(attribute)), unquote("%#{value}%"))
  end

  def handle_expr(true, attribute, [value | _]) when value in @true_values do
    handle_expr(:not_eq, attribute, [true])
  end

  def handle_expr(:not_true, attribute, [value | _]) when value in @true_values do
    handle_expr(:not_eq, attribute, [true])
  end

  def handle_expr(false, attribute, [value | _]) when value in @true_values do
    handle_expr(:eq, attribute, [false])
  end

  def handle_expr(:not_false, attribute, [value | _]) when value in @true_values do
    handle_expr(:not_eq, attribute, [false])
  end

  def handle_expr(:present, attribute, [value | _] = values) when value in @true_values do
    quote(do: not unquote(handle_expr(:blank, attribute, values)))
  end

  def handle_expr(:blank, attribute, [value | _]) when value in @true_values do
    quote(do: is_nil(unquote(field_expr(attribute))) or unquote(field_expr(attribute)) == ^'')
  end

  def handle_expr(:null, attribute, [value | _]) when value in @true_values do
    quote(do: is_nil(unquote(field_expr(attribute))))
  end

  def handle_expr(:not_null, attribute, [value | _] = values) when value in @true_values do
    quote(do: not unquote(handle_expr(:null, attribute, values)))
  end

  # def handle_expr(:between, attribute, [hd | last]) do
  #   quote do: ^unquote(hd) < unquote(field_expr(attribute)) < ^unquote(last)
  # end

  defp field_expr(%Attribute{name: name, parent: parent}) do
    quote do: field(unquote(Macro.var(parent, Elixir)), unquote(name))
  end
end
