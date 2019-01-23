defmodule Dummy.PostsTest do
  use Dummy.DataCase

  alias Dummy.Posts

  describe "posts" do
    alias Dummy.Posts.Post

    @valid_attrs %{
      body: "some body",
      like_count: 42,
      published_at: ~N[2010-04-17 14:00:00],
      title: "some title",
      user_id: 42,
      visit_count: 42
    }
    @update_attrs %{
      body: "some updated body",
      like_count: 43,
      published_at: ~N[2011-05-18 15:01:01],
      title: "some updated title",
      user_id: 43,
      visit_count: 43
    }
    @invalid_attrs %{
      body: nil,
      like_count: nil,
      published_at: nil,
      title: nil,
      user_id: nil,
      visit_count: nil
    }

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Posts.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Posts.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Posts.create_post(@valid_attrs)
      assert post.body == "some body"
      assert post.like_count == 42
      assert post.published_at == ~N[2010-04-17 14:00:00]
      assert post.title == "some title"
      assert post.user_id == 42
      assert post.visit_count == 42
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Posts.update_post(post, @update_attrs)
      assert post.body == "some updated body"
      assert post.like_count == 43
      assert post.published_at == ~N[2011-05-18 15:01:01]
      assert post.title == "some updated title"
      assert post.user_id == 43
      assert post.visit_count == 43
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
