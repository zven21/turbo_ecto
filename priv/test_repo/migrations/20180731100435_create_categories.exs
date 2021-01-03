defmodule Turbo.Ecto.TestRepo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :posts_count, :integer

      timestamps()
    end
  end
end
