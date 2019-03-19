defmodule Turbo.Ecto.Hooks.Search.Condition do
  @moduledoc false

  alias Turbo.Ecto.Hooks.Search.{Condition, Attribute}
  alias Turbo.Ecto.Services.BuildSearchQuery

  defstruct values: nil, attributes: nil, search_type: nil, combinator: nil

  @type t :: %__MODULE__{}

  def extract(key, values, module) do
    with attributes <- extract_attributes(key, module),
         search_type <- get_search_type(key),
         combinator <- get_combinator(key),
         values <- prepare_values(values),
         do: build_condition(attributes, search_type, combinator, values)
  end

  # Build attributes.
  defp extract_attributes(key, module) do
    key
    |> String.split(~r/_(and|or)_/)
    |> Enum.map(&Attribute.extract(&1, module))
    |> validate_attributes()
  end

  defp validate_attributes(attributes, acc \\ [])

  defp validate_attributes([{:error, reason} | _tail], _acc), do: {:error, reason}

  defp validate_attributes([attribute | tail], acc),
    do: validate_attributes(tail, acc ++ [attribute])

  defp validate_attributes([], acc), do: acc

  # Gets the search type, :like, :eq, etc.
  defp get_search_type(key) do
    case BuildSearchQuery.search_types()
         |> Enum.sort_by(&byte_size/1, &>=/2)
         |> Enum.find(&String.ends_with?(key, &1)) do
      nil -> {:error, :search_type_not_found}
      search_type -> String.to_atom(search_type)
    end
  end

  # Only support one symbol, priority `or`
  defp get_combinator(key) do
    cond do
      key |> String.contains?("_or_") -> :or
      key |> String.contains?("_and_") -> :and
      true -> :and
    end
  end

  # Build the search values.
  defp prepare_values(values) when is_list(values) do
    result =
      Enum.all?(values, fn
        value when is_bitstring(value) -> String.length(value) >= 1
        _ -> true
      end)

    if result, do: values, else: {:error, :value_is_empty}
  end

  defp prepare_values(value) when is_bitstring(value), do: List.wrap(value)
  defp prepare_values(value), do: List.wrap(value)

  defp build_condition({:error, reason}, _search_type, _combinator, _values), do: {:error, reason}

  defp build_condition(_attributes, _search_type, _combinator, {:error, reason}),
    do: {:error, reason}

  defp build_condition(_attributes, {:error, reason}, _combinator, _values), do: {:error, reason}

  defp build_condition(attributes, search_type, combinator, values) do
    %Condition{
      attributes: attributes,
      search_type: search_type,
      combinator: combinator,
      values: values
    }
  end
end
