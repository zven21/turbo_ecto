defmodule Dummy.Repo do
  use Ecto.Repo,
    otp_app: :dummy,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Returns the pagi data list.

  ## Examples

      iex> Scrm.Turbo.find_all(Staff, %{})
      %{entries: [], paginate: %{ current_page: 1, next_page: nil, per_page: 10, prev_page: nil, total_count: 0, total_pages: 0 } }

  """
  @spec find_all(Ecto.Schema.t() | Ecto.Queryable.t(), map(), keyword()) :: Map.t()
  def find_all(queryable, params \\ %{}, opts \\ []) do
    queryable
    |> Turbo.Ecto.turbo(params, opts)
  end
end
