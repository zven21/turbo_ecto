defmodule Dummy.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :string
      add :published_at, :naive_datetime
      add :visit_count, :integer
      add :like_count, :integer
      add :user_id, :integer

      timestamps()
    end
  end
end
