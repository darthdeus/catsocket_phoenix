defmodule Catsocket.RegistrationController do
  use Catsocket.Web, :controller

  alias Catsocket.User

  def new(conn, _params) do
    render(conn, "new.html", changeset: User.changeset(%User{}))
  end

  def create(conn, %{"user" => user_params}) do
    case register(user_params) do
      {:ok, changeset} ->
        conn
        |> put_flash(:info, "You have successfully registered and are now signed in.")
        # TODO: figure out a proper redirect path
        |> redirect(to: "/")
      {:error, changeset} ->
        #show the error message
        conn
        |> put_flash(:error, "Unable to complete the registration.")
        |> render("new.html", changeset: changeset)
    end
  end

  defp register(user_params) do
    %User{}
    |> User.changeset(user_params)
    |> Repo.insert
  end
end
