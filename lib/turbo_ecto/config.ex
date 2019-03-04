defmodule Turbo.Ecto.Config do
  @moduledoc false

  def per_page(application \\ :turbo_ecto) do
    config(:per_page, 10, application)
  end

  def repo(application \\ :turbo_ecto) do
    config(:repo, nil, application)
  end

  def entry_name(application \\ :turbo_ecto) do
    config(:entry_name, "datas", application)
  end

  def paginate_name(application \\ :turbo_ecto) do
    config(:paginate_name, "paginate", application)
  end

  def defaults do
    keys = ~w{repo per_page entry_name paginate_name}a
    Enum.map(keys, &get_defs/1)
  end

  defp get_defs(key) do
    {key, apply(__MODULE__, key, [])}
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
