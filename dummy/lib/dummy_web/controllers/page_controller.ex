defmodule DummyWeb.PageController do
  use DummyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
