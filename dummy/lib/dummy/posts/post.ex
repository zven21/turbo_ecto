defmodule Dummy.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :like_count, :integer
    field :published_at, :naive_datetime
    field :title, :string
    field :user_id, :integer
    field :visit_count, :integer

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :published_at, :visit_count, :like_count, :user_id])
    |> validate_required([:title, :body, :published_at, :visit_count, :like_count, :user_id])
  end
end
