defmodule Turbo.Ecto.Schemas.Category do
  @moduledoc false

  use Ecto.Schema

  @type t :: %__MODULE__{}

  schema "categories" do
    field(:name, :string)
    field(:posts_count, :integer)

    has_many(:posts, Turbo.Ecto.Schemas.Post)

    timestamps()
  end
end
