defmodule Turbo.Ecto.Repo do
  use Ecto.Repo,
    otp_app: :turbo_ecto,
    adapter: Ecto.Adapters.Postgres
end
