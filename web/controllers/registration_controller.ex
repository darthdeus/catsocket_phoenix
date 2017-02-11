defmodule Catsocket.RegistrationController do
  use Catsocket.Web, :controller

  alias Catsocket.User

  def new(conn, _params) do
    render(conn, "new.html", changeset: User.changeset(%User{}))
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    render(conn, "new.html", changeset: changeset)

    # TODO: implement this
    # case Registration.create(changeset, Catsocket.Repo) do
    #   {:ok, changeset} ->
    #     # sign in the user
    #     conn
    #     |> put_flash(:info, "You have successfully registered and are now signed in.")
    #     # TODO: figure out a proper redirect path
    #     |> redirect(to: "/")
    #   {:error, changeset} ->
    #     #show the error message
    #     conn
    #     |> put_flash(:info, "Unable to complete the registration.")
    #     |> render("new.html", changeset: changeset)
    # end
  end
end
