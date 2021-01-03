defmodule Turbo.Ecto.Schemas.Reply do
  @moduledoc false

  use Ecto.Schema

  schema "replies" do
    field(:content, :string)
    belongs_to(:post, Turbo.Ecto.Schemas.Post)

    timestamps()
  end
end
