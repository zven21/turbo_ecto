defmodule Turbo.EctoTest do
  @moduledoc """
  Turbo Ecto Enties Test
  """

  use Turbo.Ecto.DataCase
  doctest Turbo.Ecto

  alias Turbo.Ecto, as: TE
  alias Turbo.Ecto.Schemas.Post

  def post_fixture() do
    insert(:post,
      name: "post-name-1",
      price: 10,
      available: false,
      category: %{name: "post-name-1"}
    )

    insert(:post,
      name: "post-name-11",
      price: 20,
      available: true,
      category: %{name: "category-name-11"}
    )

    insert(:post, name: "post-name-2", price: 30, available: true)
  end

  describe "test with turbo opts" do
    test "opts with entry_name" do
      post_fixture()
      turbo_opts = [entry_name: "entries"]
      %{entries: entries} = TE.turbo(Post, %{}, turbo_opts)
      assert length(entries) == 3
    end

    test "opts with paginate_name" do
      post_fixture()
      turbo_opts = [paginate_name: "pagi"]
      %{pagi: pagi} = TE.turbo(Post, %{}, turbo_opts)

      assert pagi == %{
               current_page: 1,
               next_page: nil,
               per_page: 10,
               prev_page: nil,
               total_count: 3,
               total_pages: 1
             }
    end

    test "opts with with_paginate" do
      post_fixture()
      turbo_opts = [with_paginate: false]
      result = TE.turbo(Post, %{}, turbo_opts)
      assert length(result) == 3
    end

    test "opts with queryable callback" do
      post_fixture()

      callback = fn queryable ->
        queryable
      end

      turbo_opts = [callback: callback]
      %{datas: datas} = TE.turbo(Post, %{}, turbo_opts)
      assert length(datas) == 3
    end

    test "opts with prefix" do
      post_fixture()
      turbo_opts = [prefix: nil]
      %{datas: datas} = TE.turbo(Post, %{}, turbo_opts)
      assert length(datas) == 3
    end

    test "opts with repo" do
      post_fixture()
      turbo_opts = [repo: Turbo.Ecto.TestRepo]
      %{datas: datas} = TE.turbo(Post, %{}, turbo_opts)
      assert length(datas) == 3
    end
  end

  describe "test with assco" do
    test "combinator with :and" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_and_category_name_eq" => "post-name-1"})
      assert length(datas) == 1
    end

    test "combinator with :or" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_or_category_name_eq" => "category-name-11"})
      assert length(datas) == 1
    end
  end

  describe "test with paginate" do
    test "test with params page and per_page" do
      post_fixture()
      %{datas: datas, paginate: paginate} = TE.turbo(Post, %{"page" => 2, "per_page" => 1})

      assert length(datas) == 1

      assert paginate == %{
               current_page: 2,
               next_page: 3,
               per_page: 1,
               prev_page: 1,
               total_count: 3,
               total_pages: 3
             }
    end
  end

  describe "test with sort" do
    test "sort asc" do
      post_fixture()
      %{datas: datas} = TE.turbo(Post, %{"sort" => "price+asc"})
      assert hd(datas) |> Map.get(:price) == 10
    end

    test "sort desc" do
      post_fixture()
      %{datas: datas} = TE.turbo(Post, %{"sort" => "price+desc"})
      assert hd(datas) |> Map.get(:price) == 30
    end
  end

  describe "test search_types" do
    test "When search_types is :eq" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"price_eq" => 10})
      assert length(datas) == 1
      assert hd(datas) |> Map.get(:price) == 10
    end

    test "When search_types is :not_eq" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"price_not_eq" => 30})
      assert length(datas) == 2
    end

    test "When search_types is :lt" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"price_lt" => 20})
      assert length(datas) == 1
      assert hd(datas) |> Map.get(:price) == 10
    end

    test "When search_types is :lteq" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"price_lteq" => 20})
      assert length(datas) == 2
    end

    test "When search_types is :gt" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"price_gt" => 20})
      assert length(datas) == 1
      assert hd(datas) |> Map.get(:price) == 30
    end

    test "When search_types is :gteq" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"price_gt" => 20})
      assert length(datas) == 1
      assert hd(datas) |> Map.get(:price) == 30
    end

    test "When search_types is :is_present" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_is_present" => true})
      assert length(datas) == 3
    end

    test "When search_types is :is_blank" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_is_blank" => true})
      assert length(datas) == 0
    end

    test "When search_types is :is_null" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"replies_count_is_null" => true})
      assert length(datas) == 3
    end

    test "when search_types is :like" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_like" => "post-name-1"})
      assert length(datas) == 2
    end

    test "When search_type is :not_like" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_not_like" => "post-name-1"})
      assert length(datas) == 1
    end

    test "When search_type is :ilike" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_ilike" => "post-name-1"})
      assert length(datas) == 2
    end

    test "When search_type is :not_ilike" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_not_ilike" => "post-name-1"})
      assert length(datas) == 1
    end

    test "When search_type is :in" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"price_in" => [10, 20]})
      assert length(datas) == 2
    end

    test "When search_type is :not_in" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"price_not_in" => [10, 20]})
      assert length(datas) == 1
    end

    test "When search_type is :start_with" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_start_with" => "post-name-1"})
      assert length(datas) == 2
    end

    test "When search_type is :not_start_with" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_not_start_with" => "post-name-1"})
      assert length(datas) == 1
    end

    test "When search_type is :end_with" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_end_with" => "post-name-1"})
      assert length(datas) == 2
    end

    test "When search_type is :not_end_with" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"name_not_end_with" => "post-name-1"})
      assert length(datas) == 1
    end

    test "When search_type is :is_true" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"available_is_true" => true})
      assert length(datas) == 2
    end

    test "When search_type is :is_false" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"available_is_false" => true})
      assert length(datas) == 1
    end

    test "When search_type is :is_not_false" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"available_is_not_false" => true})
      assert length(datas) == 2
    end

    test "When search_type is between" do
      post_fixture()
      %{datas: datas} = do_run_search(%{"price_between" => [9, 21]})
      assert length(datas) == 2

      %{datas: datas_2} = do_run_search(%{"price_between" => "9..21"})
      assert length(datas_2) == 2
    end
  end

  # run search.
  defp do_run_search(filter) do
    TE.turbo(Post, %{"filter" => filter})
  end
end
