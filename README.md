
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
* [Demo](#demo)
* [Contributing](#contributing)
* [Make a pull request](#make-a-pull-request)
* [License](#license)
* [Credits](#credits)

## Getting started

* The package can be installed by adding `turbo_ecto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:turbo_ecto, "~> 0.4.1"}
  ]
end
```

* Add the Repo of your app and the desired per_page to the `turbo_ecto` configuration in `config.exs`:

```elixir
config :turbo_ecto, Turbo.Ecto,
  repo: MyApp.Repo,
  per_page: 10
```

You can also define other configurations with `entry_name` and `pagenate_name` in `config.exs`.

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

  iex> Turbo.Ecto.turbo(Turbo.Ecto.Product, params)
  %{
    datas: [%Turbo.Ecto.Product{}],
    paginate: %{
      current_page: 10,
      next_page: 11,
      per_page: 20,
      prev_page: 9,
      total_count: 100,
      total_pages: 20
    }
  }

  iex> params2 = %{"filter" => %{"name_like" => "elixir"}, "sort" => "inserted_at+asc"}}
  iex> Turbo.Ecto.turbo(Turbo.Ecto.Product, params2, [entry_name: "entries"])
  %{
    entries: [%Turbo.Ecto.Product{}],
    paginate: %{}
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
| `*_null` | is null true or false | Y | (SQL: `col is null` or `col is not null`) |
| `*_in` | match any values in array | Y | e.g. `q[name_in][]=Alice&q[name_in][]=Bob` (SQL: `name in ('Alice', 'Bob')`)|
| `*_like` | Contains value | Y | (SQL: `col LIKE '%value%'`) |
| `*_ilike` | Contains any of | Y | (SQL: `col ILIKE '%value%'`) |
| `*_true` | is true or false | Y | (SQL: `col is true or col is false`) |
| `*_between`| begin < between < end | Y | e.g. `q[price_between][]=100&q[price_between][]=200` (SQL: `100 <= price <= 200`) |


## Demo

The dummy app shows a simple turbo_ecto example.

Clone the repository.

```bash
https://github.com/zven21/turbo_ecto.git
```

Change directory

```bash
$ cd dummy
```

Run mix

```bash
$ mix deps.get && yarn --cwd=assets
```

Preparing database

```bash
$ mix ecto.setup
```

Start the Phoenix server

```bash
$ ./script/server
```

Open your browser, and visit `http://localhost:4000`

## Contributing

Bug report or pull request are welcome.

### Make a pull request

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please write unit test with your code if necessary.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


## Credits

* [ecto](https://github.com/elixir-ecto/ecto) - Very great API.
* [ransack](https://github.com/activerecord-hackery/ransack) - Initial inspiration of this project.
* [rummage_ecto](https://github.com/aditya7iyengar/rummage_ecto) - Similar implementation.