defmodule Turbo.Ecto.TestRepo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :name, :string
      add :body, :string
      add :price, :float
      add :available, :boolean
      add :replies_count, :integer
      add :category_id, :integer

      timestamps()
    end
  end
end
