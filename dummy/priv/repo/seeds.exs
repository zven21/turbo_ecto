# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Dummy.Repo.insert!(%Dummy.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

zven =
  %Dummy.Accounts.User{
    username: "zven"
  }
  |> Dummy.Repo.insert!()

for n <- 1..10 do
  %Dummy.Posts.Post{
    title: "title-#{n}",
    body: "body-#{n}"
  }
  |> Dummy.Repo.insert!()
end
