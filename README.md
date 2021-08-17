# Turbo Ecto

[![Build Status](https://travis-ci.org/zven21/turbo_ecto.svg?branch=master)](https://travis-ci.org/zven21/turbo_ecto)
[![Coverage Status](https://coveralls.io/repos/github/zven21/turbo_ecto/badge.svg)](https://coveralls.io/github/zven21/turbo_ecto)
[![Module Version](https://img.shields.io/hexpm/v/turbo_ecto.svg)](https://hex.pm/packages/turbo_ecto)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/turbo_ecto/)
[![Total Download](https://img.shields.io/hexpm/dt/turbo_ecto.svg)](https://hex.pm/packages/turbo_ecto)
[![License](https://img.shields.io/hexpm/l/turbo_ecto.svg)](https://github.com/zven21/turbo_ecto/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/zven21/turbo_ecto.svg)](https://github.com/zven21/turbo_ecto/commits/master)


Turbo is a very rich ecto component,including search sort and paginate. Inspiration by ruby [ransack](https://github.com/activerecord-hackery/ransack) and learn from [rummage_ecto](https://github.com/aditya7iyengar/rummage_ecto)

Phoenix support `turbo_html`, check [this](https://github.com/zven21/turbo_html) repos.

## Table of contents

* [Getting started](#getting-started)
* [Examples](#examples)
* [Search Matchers](#search-matchers)
* [Features](#features)
* [Contributing](#contributing)
* [Make a pull request](#make-a-pull-request)
* [License](#license)
* [Credits](#credits)

## Getting started

The package can be installed by adding `:turbo_ecto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:turbo_ecto, "~> 1.0.1"}
  ]
end
```

Add the Repo of your app and the desired per_page to the `:turbo_ecto` configuration in `config.exs`:

```elixir
config :turbo_ecto, Turbo.Ecto,
  repo: MyApp.Repo,
  per_page: 10
```

You can also define other configurations with `entry_name` and `pagenate_name` in `config.exs`.

## Examples

Category Table Structure:

Field         | Type          | Comment
------------- | ------------- | ---------
`name`        | string        |

Post Table Structure:

 Field        | Type          | Comment
------------- | ------------- | ---------
`name`        | string        |
`body`        | text          |
`price`       | float         |
`category_id` | integer       |
`available`   | boolean       |

```elixir
iex> params = %{
      "q" => %{"name_and_category_name_like" => "elixir"},
      "s" => "inserted_at+asc",
      "page" = 0,
      "per_page" => 20
     }

iex> Turbo.Ecto.turbo(Turbo.Ecto.Schemas.Post, params)
%{
  datas: [%Turbo.Ecto.Schemas.Post{}],
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

### The 2 more commonly used API are as follows：

#### `Turbo.Ecto.turbo(queryable, params, opts \\ [])`

* 1 queryable: receives a schema object or an Ecto.Query.t() object

* 2 params: supports 4 parameters.
  - `q` or `filter` to receive pattern matching information, e.g. ```params = %{"q" ⇒ %{"name_like" ⇒ "elixir"}}``` or ```params = %{"filter" ⇒ %{"name_like" ⇒ "elixir"}```
  - `s` or `sort` Receive sort information. e.g. ```params = %{"sort" ⇒ "position+asc"}``` or ```params = %{"s" ⇒ "inserted_at+desc"}```
  - `page` Receive query page number. e.g. ```params = %{"page" ⇒ 1}```
  - `per_page` Receive the number of pages. e.g. ```params = %{"per_page" ⇒ 20}```

* 3 opts: currently receives the following information:
  - `paginate_name`: sets the pagination key value of the returned result
  - `entry_name`: sets the key value of the returned result object
  - `prefix`: table prefix
  - `with_paginate`: whether to include pagination information, default `true`
  - `callback`: callback processing for `queryable`

#### `Turbo.Ecto.turboq(queryable, params, opts)`

Returns an Ecto.Query.t() object

More example pls move: [docs](https://hexdocs.pm/turbo_ecto/api-reference.html)

## Search Matchers

List of all possible `search_types`:

Predicate         | Description               | Note
----------------- | -----------------------   | ----
`*_eq`            | equal                     | SQL: `col = 'value'`
`*_not_eq`        | not equal                 | SQL: `col != 'value'`
`*_lt`            | less than                 | SQL: `col < 1024`
`*_lteq`          | less than or equal        | SQL: `col <= 1024`
`*_gt`            | greater than              | SQL: `col > 1024`
`*_gteq`          | greater than or equal     | SQL: `col >= 1024`
`*_is_present`    | not null and not empty    | Only compatible with string columns. e.g.: `q[name_present  ]=1` SQL: `col is not null AND col != ''`
`*_is_null`       | is null true or false     | SQL: `col is null` or `col is not null`
`*_like`          | contains value            | SQL: `col LIKE '%value%'`
`*_ilike`         | contains any of           | SQL: `col ILIKE '%value%'`
`*_is_true`       | is true or false          | SQL: `col is true or col is false`
`*_is_not_true`   | is true or false          | SQL: `col is not true or col is false`
`*_is_false`      | is true or false          | SQL: `col is false`
`*_is_not_false`  | is true or false          | SQL: `col is not false`
`*_is_null`       | is null                   | SQL: `col is nil`
`*_is_not_null`   | is not null               | SQL: `col is not nil`
`*_in`            | match any values in array | e.g.: `q[name_in][]=Alice&q[name_in][]=Bob` SQL: `name in ('Alice', 'Bob')`
`*_not_in`        | not contains              | SQL: `col not in ('Alice', 'Bob')`
`*_start_with`    | start with values         | SQL: `col LIKE '%value'`
`*_not_start_with`| not start with values     | SQL: `col not LIKE '%value'`
`*_end_with`      | end with values           | SQL: `col LIKE 'value%'`
`*_not_end_with`  | not end with values       | e.g.: `q[name_not_end_with][]=Alice` SQL: `col not LIKE 'value%'  `
`*_between`       | begin < between < end     | e.g.: `q[price_between][]=100&q[price_between][]=200` SQL: `100 <=   price and price <= 200`)

## Contributing

Bug report or pull request are welcome.

### Make a pull request

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please write unit test with your code if necessary.

## Copyright and License

Copyright (c) 2018 Zven Wang

The library is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


## Credits

* [ecto](https://github.com/elixir-ecto/ecto) - Very great API.
* [ransack](https://github.com/activerecord-hackery/ransack) - Initial inspiration of this project.
* [rummage_ecto](https://github.com/aditya7iyengar/rummage_ecto) - Similar implementation.
