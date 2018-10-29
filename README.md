
# Turbo Ecto

[![Build Status](https://travis-ci.org/zven21/turbo_ecto.svg?branch=master)](https://travis-ci.org/zven21/turbo_ecto)
[![Coverage Status](https://coveralls.io/repos/github/zven21/turbo_ecto/badge.svg)](https://coveralls.io/github/zven21/turbo_ecto)

Turbo is a very rich ecto component,including search sort and paginate. Inspiration by ruby [ransack](https://github.com/activerecord-hackery/ransack) and learn from [rummage_ecto](https://github.com/aditya7iyengar/rummage_ecto)

Phoenix support `turbo_html`, check [this](https://github.com/zven21/turbo_html) repos.

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
    {:turbo_ecto, "~> 0.1.7"}
  ]
end
```

* Add the Repo of your app and the desired per_page to the `turbo_ecto` configuration in config.exs:

```elixir
config :turbo_ecto, Turbo.Ecto,
  repo: MyApp.Repo,
  per_page: 10
```

## Examples

* Category Table Structure

    |  Field | Type | Comment |
    | ------------- | ------------- | --------- |
    | `name`  | string  |  |

* Product Table Structure

    |  Field | Type | Comment |
    | ------------- | ------------- | --------- |
    | `name`  | string  |  |
    | `body` | text |  |
    | `price` | float |  |
    | `category_id` | integer | |
    | `available` | boolean |  |

* Variant Table Structure

    |  Field | Type | Comment |
    | ------------- | ------------- | --------- |
    | `name`  | string  |  |
    | `price` | float |  |
    | `product_id` | integer | |

```elixir

  iex> params = %{"q" => %{"product_category_name_and_product_name_or_name_like" => "elixir"}, "s" => "inserted_at+asc"}

  iex> Turbo.Ecto.turboq(Turbo.Ecto.Variant, params)
  #Ecto.Query<from v in Turbo.Ecto.Variant, join: p0 in assoc(v, :product),
  join: p1 in assoc(v, :product), join: c in assoc(p1, :category),
  or_where: like(v.name, ^"%elixir%"), where: like(p0.name, ^"%elixir%"),
  where: like(c.name, ^"%elixir%"), order_by: [asc: c.inserted_at], limit: ^10,
  offset: ^0>

  iex> Turbo.Ecto.turbo(Turbo.Ecto.Variant, params)
  %{
    datas: [Variant],
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
| `*_not_eq` | not equal | Y | (SQL: `col != 'value'`) |
| `*_lt` | less than | Y | (SQL: `col < 1024`) |
| `*_lteq` | less than or equal | Y |  (SQL: `col <= 1024`) |
| `*_gt` | greater than | Y | (SQL: `col > 1024`) |
| `*_gteq` | greater than or equal | Y | greater than or equal. (SQL: `col >= 1024`) |
| `*_present` | not null and not empty | Y | Only compatible with string columns. Example: `q[name_present]=1` (SQL: `col is not null AND col != ''`) |
| `*_is_null` | is null true or false | Y | (SQL: `col is null` or `col is not null`) |
| `*_in` | match any values in array | Y | e.g. `q[name_in][]=Alice&q[name_in][]=Bob` (SQL: `name in ('Alice', 'Bob')`)|
| `*_like` | Contains value | Y | (SQL: `col LIKE '%value%'`) |
| `*_ilike` | Contains any of | Y | (SQL: `col ILIKE '%value%'`) |
| `*_is_true` | is true or false | Y | (SQL: `col is true or col is false`) |
| `*_between`| begin < between < end | Y | e.g. `q[price_between][]=100&q[price_between][]=200` (SQL: `100 <= price <= 200`) |

## Credits

* [ecto](https://github.com/elixir-ecto/ecto) - Very great API.
* [ransack](https://github.com/activerecord-hackery/ransack) - Initial inspiration of this project.
* [rummage_ecto](https://github.com/aditya7iyengar/rummage_ecto) - Similar implementation.
