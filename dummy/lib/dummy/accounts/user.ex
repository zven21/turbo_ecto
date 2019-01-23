defmodule Dummy.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :age, :string
    field :email, :string
    field :gender, :boolean, default: false
    field :mobile, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :mobile, :email, :age, :gender])
    |> validate_required([:username, :mobile, :email, :age, :gender])
  end
end
