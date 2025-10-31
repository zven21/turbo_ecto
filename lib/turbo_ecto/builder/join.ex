defmodule Turbo.Ecto.Builder.Join do
  @moduledoc false

  @doc """
  Builds a quoted join expression.

  ## Example

      iex> query = Turbo.Ecto.Schemas.Post
      iex> relations = [:category, :repleis]
      iex> Turbo.Ecto.Builder.Join.build(query, relations)
      #Ecto.Query<from p0 in Turbo.Ecto.Schemas.Post, join: c1 in assoc(p0, :category), as: :category, join: r2 in assoc(p0, :repleis), as: :repleis>

  """
  @spec build(Ecto.Query.t(), [atom()]) :: Ecto.Query.t()
  def build(query, relations) do
    relations |> Enum.reduce(query, &apply_join(&1, &2))
  end

  @spec apply_join(atom(), Ecto.Queryable.t()) :: Ecto.Query.t()
  def apply_join(relation, query) do
    quoted =
      quote do
        import Ecto.Query

        from(q in unquote(Macro.escape(query)),
          join: r in assoc(q, unquote(relation)),
          as: unquote(relation)
        )
      end

    quoted
    |> Code.eval_quoted([], __ENV__)
    |> elem(0)
  end
end
