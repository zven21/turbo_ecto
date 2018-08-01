defmodule Turbo.Ecto.Config do
  @moduledoc false

  def per_page(application \\ :turbo_ecto) do
    config(:per_page, 10, application)
  end

  def repo(application \\ :turbo_ecto) do
    config(:repo, nil, application)
  end

  defp config(application) do
    Application.get_env(application, Turbo.Ecto, [])
  end

  defp config(key, default, application) do
    application
    |> config()
    |> Keyword.get(key, default)
    |> resolve_config(default)
  end

  defp resolve_config(value, _default), do: value
end