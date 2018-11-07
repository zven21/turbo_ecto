defmodule Turbo.Ecto.Builder.LimitOffset do
  @moduledoc false

  alias Ecto.Query.Builder.LimitOffset

  @doc """
  val = 1
  """
  @spec build(:limit | :offset, Macro.t(), [Macro.t()], Macro.t()) :: Macro.t()
  def build(type, query, val, binding) do
    type
    |> LimitOffset.build(Macro.escape(query), binding, val, __ENV__)
    |> Code.eval_quoted()
    |> elem(0)
  end

  # def expr(val) do
  # end
end
