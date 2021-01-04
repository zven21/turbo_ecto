Mix.Task.run("ecto.drop", ["quiet", "-r", "Turbo.Ecto.TestRepo"])
Mix.Task.run("ecto.create", ["quiet", "-r", "Turbo.Ecto.TestRepo"])
Mix.Task.run("ecto.migrate", ["-r", "Turbo.Ecto.TestRepo"])

{:ok, _} = Application.ensure_all_started(:ex_machina)

Turbo.Ecto.TestRepo.start_link()
ExUnit.start()
