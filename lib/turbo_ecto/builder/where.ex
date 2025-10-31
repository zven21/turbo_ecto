defmodule Turbo.Ecto.Builder.Where do
  @moduledoc false

  import Ecto.Query
  alias Turbo.Ecto.Hooks.Search
  alias Search.Condition

  @doc false
  def build(query, %Search{combinator: combinator} = grouping, _binding)
      when combinator in ~w(and or)a do
    case grouping_dynamic(grouping) do
      nil -> query
      expr -> where(query, ^expr)
    end
  end

  # deprecated AST builder functions removed (unused)

  # dynamic builder (uses named bindings via as(:parent))
  defp grouping_dynamic(%Search{conditions: []}), do: nil

  defp grouping_dynamic(%Search{combinator: combinator, conditions: conditions}) do
    Enum.reduce(conditions, nil, fn condition, acc ->
      cond_expr = condition_dynamic(condition)
      combine(acc, cond_expr, combinator)
    end)
  end

  defp condition_dynamic(%Condition{attributes: [], values: _v}), do: nil

  defp condition_dynamic(%Condition{
         attributes: attrs,
         values: vals,
         search_type: st,
         combinator: comb
       }) do
    Enum.reduce(attrs, nil, fn %{parent: parent, name: name}, acc ->
      expr = handle_expr_dynamic(st, parent, name, vals)
      combine(acc, expr, comb)
    end)
  end

  defp combine(nil, expr, _), do: expr
  defp combine(expr, nil, _), do: expr
  defp combine(left, right, :and), do: dynamic(^left and ^right)
  defp combine(left, right, :or), do: dynamic(^left or ^right)

  defp handle_expr_dynamic(:eq, parent, name, [v | _]),
    do: dynamic(field(as(^parent), ^name) == ^v)

  defp handle_expr_dynamic(:not_eq, parent, name, [v | _]),
    do: dynamic(field(as(^parent), ^name) != ^v)

  defp handle_expr_dynamic(:lt, parent, name, [v | _]),
    do: dynamic(field(as(^parent), ^name) < ^v)

  defp handle_expr_dynamic(:lteq, parent, name, [v | _]),
    do: dynamic(field(as(^parent), ^name) <= ^v)

  defp handle_expr_dynamic(:gt, parent, name, [v | _]),
    do: dynamic(field(as(^parent), ^name) > ^v)

  defp handle_expr_dynamic(:gteq, parent, name, [v | _]),
    do: dynamic(field(as(^parent), ^name) >= ^v)

  defp handle_expr_dynamic(:like, parent, name, [v | _]),
    do: dynamic(like(field(as(^parent), ^name), ^("%" <> to_string(v) <> "%")))

  defp handle_expr_dynamic(:not_like, parent, name, [v | _]),
    do: dynamic(not like(field(as(^parent), ^name), ^("%" <> to_string(v) <> "%")))

  defp handle_expr_dynamic(:ilike, parent, name, [v | _]),
    do: dynamic(ilike(field(as(^parent), ^name), ^("%" <> to_string(v) <> "%")))

  defp handle_expr_dynamic(:not_ilike, parent, name, [v | _]),
    do: dynamic(not ilike(field(as(^parent), ^name), ^("%" <> to_string(v) <> "%")))

  defp handle_expr_dynamic(:in, parent, name, vs), do: dynamic(field(as(^parent), ^name) in ^vs)

  defp handle_expr_dynamic(:not_in, parent, name, vs),
    do: dynamic(field(as(^parent), ^name) not in ^vs)

  defp handle_expr_dynamic(:start_with, parent, name, [v | _]),
    do: dynamic(ilike(field(as(^parent), ^name), ^(to_string(v) <> "%")))

  defp handle_expr_dynamic(:not_start_with, parent, name, [v | _]),
    do: dynamic(not ilike(field(as(^parent), ^name), ^(to_string(v) <> "%")))

  # Note: historical semantics: *_end_with behaves like contains ("%value%") per tests
  defp handle_expr_dynamic(:end_with, parent, name, [v | _]),
    do: dynamic(ilike(field(as(^parent), ^name), ^("%" <> to_string(v) <> "%")))

  defp handle_expr_dynamic(:not_end_with, parent, name, [v | _]),
    do: dynamic(not ilike(field(as(^parent), ^name), ^("%" <> to_string(v) <> "%")))

  defp handle_expr_dynamic(:between, parent, name, [min, max]),
    do: dynamic(^min < field(as(^parent), ^name) and field(as(^parent), ^name) < ^max)

  defp handle_expr_dynamic(:between, parent, name, [v | _]) when is_binary(v) do
    [min, max] = String.split(v, "..")
    dynamic(^min < field(as(^parent), ^name) and field(as(^parent), ^name) < ^max)
  end

  defp handle_expr_dynamic(:is_null, parent, name, [flag | _])
       when flag in [true, 1, "1", "true", ~c"1", ~c"T", ~c"t"],
       do: dynamic(is_nil(field(as(^parent), ^name)))

  defp handle_expr_dynamic(:is_null, parent, name, _),
    do: dynamic(not is_nil(field(as(^parent), ^name)))

  defp handle_expr_dynamic(:is_blank, parent, name, [flag | _])
       when flag in [true, 1, "1", "true", ~c"1", ~c"T", ~c"t"],
       do: dynamic(is_nil(field(as(^parent), ^name)) or field(as(^parent), ^name) == ^"")

  defp handle_expr_dynamic(:is_present, parent, name, [flag | _])
       when flag in [true, 1, "1", "true", ~c"1", ~c"T", ~c"t"],
       do: dynamic(not (is_nil(field(as(^parent), ^name)) or field(as(^parent), ^name) == ^""))

  defp handle_expr_dynamic(:is_true, parent, name, _),
    do: dynamic(field(as(^parent), ^name) == ^true)

  defp handle_expr_dynamic(:is_not_true, parent, name, _),
    do: dynamic(field(as(^parent), ^name) != ^true)

  defp handle_expr_dynamic(:is_false, parent, name, _),
    do: dynamic(field(as(^parent), ^name) == ^false)

  defp handle_expr_dynamic(:is_not_false, parent, name, _),
    do: dynamic(field(as(^parent), ^name) != ^false)
end
