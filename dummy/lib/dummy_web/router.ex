defmodule DummyWeb.Router do
  use DummyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DummyWeb do
    pipe_through :browser

    get "/", PostController, :index

    resources "/users", UserController
    resources "/posts", PostController
  end

  # Other scopes may use custom stacks.
  # scope "/api", DummyWeb do
  #   pipe_through :api
  # end
end
