defmodule Turbo.Ecto.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :body, :string
      add :price, :float
      add :available, :boolean
      add :category_id, :integer

      timestamps()
    end
  end
end
