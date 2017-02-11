defmodule Catsocket.Router do
  use Catsocket.Web, :router

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

  scope "/", Catsocket do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/docs", PageController, :docs

    get "/login", SessionController, :new

    resources "/projects", ProjectController, only: [:index]
    resources "/password", PasswordController, only: [:new]
    resources "/sessions", SessionController, only: [:create, :destroy]
    resources "/registrations", RegistrationController, only: [:new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Catsocket do
  #   pipe_through :api
  # end
end
