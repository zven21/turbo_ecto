defmodule Dummy.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :mobile, :string
      add :email, :string
      add :age, :string
      add :gender, :boolean, default: false, null: false

      timestamps()
    end
  end
end
