defmodule Turbo.Ecto.TestRepo do
  use Ecto.Repo,
    otp_app: :turbo_ecto,
    adapter: Ecto.Adapters.Postgres
end
