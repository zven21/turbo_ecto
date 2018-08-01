defmodule Turbo.Ecto.Product do
  @moduledoc false

  use Ecto.Schema
  use Turbo.Ecto

  schema "products" do
    field :name, :string
    field :body, :string
    field :price, :float
    field :available, :boolean

    belongs_to :category, Turbo.Ecto.Category
    has_many :variants, Turbo.Ecto.Variant

    timestamps()
  end
end