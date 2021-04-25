defmodule Dummy.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :mobile, :string
    field :nickname, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :mobile, :email])
    |> validate_required([:nickname, :mobile, :email])
  end
end
