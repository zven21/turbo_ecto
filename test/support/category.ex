defmodule Turbo.Ecto.Category do
  @moduledoc false

  use Ecto.Schema

  schema "categories" do
    field(:name, :string)

    has_many(:products, Turbo.Ecto.Product)

    timestamps()
  end
end
