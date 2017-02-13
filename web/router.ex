defmodule Catsocket.Router do
  use Catsocket.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Catsocket.Plugs.AssignUser
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
    post "/login", SessionController, :create
    delete "/logout", SessionController, :destroy

    resources "/projects", ProjectController, only: [:index]
    resources "/password", PasswordController, only: [:new]
    resources "/registrations", RegistrationController, only: [:new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Catsocket do
  #   pipe_through :api
  # end
end
