
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

```elixir

  iex> params = %{"q" => %{"name_and_category_name_like" => "elixir"}, "s" => "inserted_at+asc", "per_page" => 20}

  iex> Turbo.Ecto.turboq(Turbo.Ecto.Product, params)
  #Ecto.Query<from p in Turbo.Ecto.Product, join: c in assoc(p, :category),
  where: like(p.name, "%elixir%") and like(c.name, "%elixir%"),
  order_by: [asc: p.inserted_at], limit: 20, offset: 0>

  iex> Turbo.Ecto.turbo(Turbo.Ecto.Product, params)
  %{
    datas: [%Product{}],
    paginate: %{
      current_page: 10,
      next_page: 11,
      per_page: 20,
      prev_page: 9,
      total_count: 100,
      total_pages: 20
    }
  }

```

More example pls move: [docs](https://hexdocs.pm/turbo_ecto/api-reference.html)

## Search Matchers

List of all possible search_types

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
