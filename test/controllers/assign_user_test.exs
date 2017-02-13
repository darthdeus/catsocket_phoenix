defmodule Catsocket.AssignUserTest do
  use Catsocket.ConnCase

  alias Catsocket.Plugs.AssignUser
  import Catsocket.Factory

  test "doesn't assign anything if the session is empty", %{conn: conn} do
    conn = conn
           |> get("/")
           |> AssignUser.call([])

    refute get_session(conn, :current_user)
  end

  test "doesn't assign anything if the session contains an invalid user id", %{session_conn: conn} do
    conn = conn
           |> put_session(:current_user, Ecto.UUID.generate())
           |> AssignUser.call([])

    refute conn.assigns[:current_user]
  end

	test "assigns the user that is present in the session", %{session_conn: conn} do
    user = insert(:user)

    conn = conn
           |> put_session(:current_user, user.id)
           |> AssignUser.call([])

    assert conn.assigns[:current_user]
	end
end
