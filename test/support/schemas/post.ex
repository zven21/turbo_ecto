defmodule Turbo.Ecto.Schemas.Post do
  @moduledoc false

  use Ecto.Schema

  schema "posts" do
    field(:name, :string)
    field(:body, :string)
    field(:price, :float)
    field(:available, :boolean)
    field(:replies_count, :integer)

    belongs_to(:category, Turbo.Ecto.Schemas.Category)
    has_many(:replies, Turbo.Ecto.Schemas.Reply)

    timestamps()
  end
end
