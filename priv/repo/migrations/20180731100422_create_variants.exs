defmodule Turbo.Ecto.Repo.Migrations.CreateVariants do
  use Ecto.Migration

  def change do
    create table(:variants) do
      add :name,    :string
      add :price,   :float
      add :length,  :string
      add :height,  :string
      add :width,   :string
      add :product_id, :integer

      timestamps()
    end
  end
end
