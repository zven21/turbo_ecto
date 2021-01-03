defmodule Turbo.Ecto.TestRepo.Migrations.CreateReplies do
  use Ecto.Migration

  def change do
    create table(:replies) do
      add :content, :string
      add :post_id, :integer

      timestamps()
    end
  end
end
