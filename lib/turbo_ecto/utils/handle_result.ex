defmodule Turbo.Ecto.Utils.HandleResult do
  @moduledoc """
  Utils func
  """

  def done({:error, reason}), do: {:error, reason}
  def done(result), do: {:ok, result}
end
