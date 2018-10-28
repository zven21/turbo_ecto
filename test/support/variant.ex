defmodule Turbo.Ecto.Variant do
  @moduledoc false

  use Ecto.Schema

  schema "variants" do
    field(:name, :string)
    field(:price, :float)
    field(:length, :string)
    field(:width, :string)
    field(:height, :string)

    belongs_to(:product, Turbo.Ecto.Product)
    has_many(:prototypes, Turbo.Ecto.ProtoType)

    timestamps()
  end
end
