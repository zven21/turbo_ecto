defmodule Dummy.Repo do
  use Ecto.Repo,
    otp_app: :dummy,
    adapter: Ecto.Adapters.Postgres
end
