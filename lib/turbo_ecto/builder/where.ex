defmodule Turbo.Ecto.Builder.Where do
  @moduledoc false

  alias Ecto.Query.Builder.Filter
  alias Turbo.Ecto.Hooks.Search
  alias Search.Condition
  alias Turbo.Ecto.Services.BuildSearchQuery

  @doc """
  """
  # @spec
  def build(query, %Search{combinator: combinator} = grouping, binding)
      when combinator in ~w(and or)a do
    exprs = grouping |> List.wrap() |> groupings_expr()

    :where
    |> Filter.build(combinator, Macro.escape(query), binding, exprs, __ENV__)
    |> Code.eval_quoted()
    |> elem(0)
  end

  defp grouping_expr(%Search{conditions: []}) do
    []
  end

  defp grouping_expr(%Search{combinator: combinator, conditions: conditions}) do
    conditions |> Enum.map(&condition_expr/1) |> combinator_expr(combinator)
  end

  defp condition_expr(%Condition{
         attributes: attrs,
         values: vals,
         search_type: search_type,
         combinator: combinator
       }) do
    attrs
    |> Enum.map(&BuildSearchQuery.handle_expr(search_type, &1, vals))
    |> combinator_expr(combinator)
  end

  defp groupings_expr(groupings), do: groupings_expr(groupings, [], nil)
  defp groupings_expr([%{groupings: []} = parent], [], nil), do: grouping_expr(parent)

  defp groupings_expr([%{groupings: []} = parent | tail], acc, combinator_acc) do
    groupings_expr(tail, acc ++ [grouping_expr(parent)], combinator_acc)
  end

  defp groupings_expr(
         [%{combinator: combinator, groupings: children} = parent | tail],
         acc,
         combinator_acc
       ) do
    children_exprs = groupings_expr(children, acc ++ [grouping_expr(parent)], combinator)
    groupings_expr(tail, children_exprs, combinator_acc)
  end

  defp groupings_expr([], acc, nil), do: acc
  defp groupings_expr([], acc, combinator), do: combinator_expr(acc, combinator)

  defp combinator_expr(exprs, combinator, acc \\ [])

  defp combinator_expr([first_expr, second_expr | tail], combinator, acc) do
    tail_exprs =
      combinator_expr(
        tail,
        combinator,
        quote do
          unquote(combinator)(unquote_splicing([first_expr, second_expr]))
        end
      )

    combinator_expr([tail_exprs], combinator, acc)
  end

  defp combinator_expr([expr], _combinator, []),
    do: expr

  defp combinator_expr([expr], combinator, acc),
    do: quote(do: unquote(combinator)(unquote(expr), unquote(acc)))

  defp combinator_expr([], _combinator, acc),
    do: acc
end
