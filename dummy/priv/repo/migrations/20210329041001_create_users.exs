defmodule Dummy.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :nickname, :string
      add :mobile, :string
      add :email, :string

      timestamps()
    end
  end
end
