{:ok, _} = Application.ensure_all_started(:ex_machina)

Turbo.Ecto.TestRepo.start_link()
ExUnit.start()
