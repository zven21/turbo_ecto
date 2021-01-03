defmodule Turbo.Ecto.TestFactory do
  @moduledoc false

  # with Ecto
  use ExMachina.Ecto, repo: Turbo.Ecto.TestRepo

  alias Turbo.Ecto.Schemas.{Category, Post, Reply}

  def category_factory do
    %Category{
      name: sequence(:name, &"category-name#{&1}")
      # posts: build_pair(:post)
    }
  end

  @doc """
  """
  def post_factory do
    %Post{
      name: sequence(:name, &"post-name#{&1}"),
      body: sequence(:body, &"post-body#{&1}"),
      category: build(:category),
      replies: build_pair(:reply)
    }
  end

  @doc """
  """
  def reply_factory do
    %Reply{
      content: sequence(:content, &"content-#{&1}")
      # product: build(:product)
    }
  end
end
