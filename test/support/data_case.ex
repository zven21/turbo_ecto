defmodule Turbo.Ecto.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import Turbo.Ecto.TestFactory
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Turbo.Ecto.TestRepo)
  end
end
