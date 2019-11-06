defmodule Turbo.Ecto.Builder.LimitOffset do
  @moduledoc false

  alias Ecto.Query.Builder.LimitOffset

  @doc """
  Builds a quoted limit or offset expression.

  ## Examples

  When type is `:limit`:
      iex> type = :limit
      iex> query = Turbo.Ecto.Product
      iex> val = 1
      iex> Turbo.Ecto.Builder.LimitOffset.build(type, query, val, [])
      #Ecto.Query<from p0 in Turbo.Ecto.Product, limit: 1>

  When type is `:offset`:
      iex> type = :offset
      iex> query = Turbo.Ecto.Product
      iex> val = 1
      iex> Turbo.Ecto.Builder.LimitOffset.build(type, query, val, [])
      #Ecto.Query<from p0 in Turbo.Ecto.Product, offset: 1>

  """
  @spec build(:limit | :offset, Ecto.Query.t(), integer(), Macro.t()) :: Ecto.Query.t()
  def build(type, query, val, binding) do
    type
    |> LimitOffset.build(Macro.escape(query), binding, val, __ENV__)
    |> Code.eval_quoted()
    |> elem(0)
  end

  # def expr(val) do
  # end
end
