defmodule Turbo.Ecto.Utils do
  @moduledoc """
  Utils func
  """

  def done({:error, reason}), do: {:error, reason}
  def done(result), do: {:ok, result}

  @doc """
  Converts all (string) map keys to atoms

  ## Examples

      iex> map = %{"a" => 1, "b" => %{"c" => 3, "d" => 4}}
      iex> symbolize_keys(map)
      %{a: 1, b: %{c: 3, d: 4}}

  """
  @spec symbolize_keys(map()) :: map()
  def symbolize_keys(map) do
    Enum.reduce(map, %{}, fn {k, v}, m ->
      v =
        case is_map(v) do
          true -> symbolize_keys(v)
          false -> v
        end

      map_atom_put(m, k, v)
    end)
  end

  defp map_atom_put(m, k, v) do
    if is_binary(k), do: Map.put(m, String.to_atom(k), v), else: Map.put(m, k, v)
  end

  @doc """
  Converts all (atoms) map keys to string.

  ## Example

    iex> map = %{a: 1, b: %{c: 3, d: 4}}
    iex> stringify_keys(map)
    %{"a" => 1, "b" => %{"c" => 3, "d" => 4}}

  """
  @spec stringify_keys(map()) :: map()
  def stringify_keys(map = %{}) do
    Enum.into(map, %{}, fn {k, v} -> {to_string(k), stringify_keys(v)} end)
  end

  def stringify_keys([head | rest]) do
    [stringify_keys(head) | stringify_keys(rest)]
  end

  def stringify_keys(not_a_map) do
    not_a_map
  end
end
