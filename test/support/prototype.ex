defmodule Turbo.Ecto.ProtoType do
  @moduledoc false

  use Ecto.Schema

  schema "prototypes" do
    field(:name, :string)
    field(:summary, :float)

    belongs_to(:variant, Turbo.Ecto.Variant)

    timestamps()
  end
end
