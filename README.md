
# Turbo Ecto

[![Build Status](https://travis-ci.org/zven21/turbo_ecto.svg?branch=master)](https://travis-ci.org/zven21/turbo_ecto)

Turbo is a very rich ecto component,including search sort and paginate. Inspiration by ruby [ransack](https://github.com/activerecord-hackery/ransack) and learn from [rummage_ecto](https://github.com/aditya7iyengar/rummage_ecto)

## Table of contents

* [Getting started](#getting-started)
* [Examples](#examples)
* [Search Matchers](#search-matchers)
* [Features](#features)
* [Credits](#credits)

## Getting started

* The package can be installed by adding `turbo_ecto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:turbo_ecto, "~> 0.1.0"}
  ]
end
```

* Add the Repo of your app and the desired per_page to the `turbo_ecto` configuration in config.exs:

```elixir
config :turbo_ecto, Turbo.Ecto,
  repo: MyApp.Repo,
  per_page: 10
```

* Or add the `turbo_ecto` with elixir `use`

```elixir
use Turbo.Ecto, repo: MyApp.Repo, per_page: 10
```

## Examples

```elixir
iex> params = %{
  "q" => %{"title_like" => "hello123", "category_id_eq" => 1},
  "s" => "inserted_at+asc",
  "per_page" => 5, "page" => 10
}

iex> Turbo.Ecto.turboq(Product, params)
#Ecto.Query<from t in Product, where: t.type == ^1,
  where: like(t.title, ^"%hello123%"),
  order_by: [asc: t.inserted_at],
  limit: ^5, offset: ^45>

iex> Turbo.Ecto.turbo(Product, params)
%{
  datas: [Product.t()],
  paginate: %{
    current_page: 10,
    next_page: 11,
    per_page: 5,
    prev_page: 9,
    total_count: 100,
    total_pages: 20
  }
}

```

Also supports:

* Use `Turbo.Ecto.search` only returns search `result` or use `Turbo.Ecto.searchq` returns search `queryable`;
* Use `Turbo.Ecto.sort` only returns sort `result` or use `Turbo.Ecto.sortq` returns sort `queryable`;
* Use `Turbo.Ecto.paginate` returns pagiante `result` or use `Turbo.Ecto.paginateq` returns paginate `queryable`.

More example pls move: [docs](https://hexdocs.pm/turbo_ecto/api-reference.html)

## Search Matchers

List of all possible predicates

| Predicate | Description | Finish | Note
| ------------- | ------------- |-------- |-------- |
| `*_eq`  | equal  | Y | (SQL: `col = 'value'`) |
| `*_not_eq` | not equal | N | (SQL: `col != 'value'`) |
| `*_lt` | less than | Y | (SQL: `col < 1024`) |
| `*_lteq` | less than or equal | Y |  (SQL: `col <= 1024`) |
| `*_gt` | greater than | Y | (SQL: `col > 1024`) |
| `*_gteq` | greater than or equal | Y | greater than or equal. (SQL: `col >= 1024`) |
| `*_present` | not null and not empty | N | Only compatible with string columns. Example: `q[name_present]=1` (SQL: `col is not null AND col != ''`) |
| `*_blank` | is null or empty. | N | (SQL: `col is null OR col = ''`) |
| `*_is_null` | is null true or false | N | (SQL: `col is null` or `col is not null`) |
| `*_in` | match any values in array | N | e.g. `q[name_in][]=Alice&q[name_in][]=Bob` (SQL: `name in ('Alice', 'Bob')`)|
| `*_start_with` | Starts with | N | (SQL: `col LIKE 'value%'`) |
| `*_not_start_with` | Does not start with | N | |
| `*_end_with` | Ends with | N | (SQL: `col LIKE '%value'`)|
| `*_not_end_with` | Does not end with | N | |
| `*_like` | Contains value | Y | (SQL: `col LIKE '%value%'`) |
| `*_ilike` | Contains any of | Y | (SQL: `col ILIKE '%value%'`) |
| `*_is_true` | is true or false | N | (SQL: `col is true or col is false`) |
| `*_between`| begin < between < end | N | e.g. `q[price_between][]=100&q[price_between][]=200` (SQL: `100 <= price <= 200`) |

## Features

* [ ] Example website.
* [x] Add the necessary code test.
* [ ] Support `and` and `or` symbol. Example: e.g. `q[title_or_body_like]=hello123`, SQL: `title LIKE 'hello123' or body LIKE 'hello123'`
* [ ] Support multi table assoc search. Example: e.g. `q[category_name_like]=cate1`.
* [ ] Support multi table assoc sort. Example: e.g. `s=category_updated_at+desc`

## Credits

* [ecto](https://github.com/elixir-ecto/ecto) - Very great API.
* [ransack](https://github.com/activerecord-hackery/ransack) - Initial inspiration of this project.
* [rummage_ecto](https://github.com/aditya7iyengar/rummage_ecto) - Similar implementation.
