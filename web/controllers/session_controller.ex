defmodule Catsocket.SessionController do
  use Catsocket.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias Catsocket.User

  # TODO: enable this while also returning proper errors if params are missing
  # plug :scrub_params, "session" when action in [:create]

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => session_params}) do
    if session_params["email"] do
      Repo.get_by(User, email: session_params["email"])
      |> login(session_params["password"], conn)
    else
      dummy_checkpw()

      login_failed(conn)
    end
  end

  def destroy(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "You were logged out successfully.")
    |> assign(:current_user, nil)
    |> redirect(to: "/")
  end

  ### Private API

  defp login(user, _, conn) when is_nil(user) do
    dummy_checkpw()

    login_failed(conn)
  end

  defp login(user, password, conn) do
    if checkpw(password, user.encrypted_password) do
      conn
      |> put_session(:current_user, user.id)
      |> put_flash(:info, "You have successfully logged in.")
      |> redirect(to: "/")
    else
      login_failed(conn)
    end
  end

  defp login_failed(conn) do
    conn
    |> put_flash(:error, "Invalid combination of email and password.")
    |> render("new.html")
  end
end
