defmodule Catsocket.AssignUserTest do
  use Catsocket.ConnCase

  alias Catsocket.User
  alias Catsocket.Plugs.AssignUser
  import Catsocket.Factory

  @session Plug.Session.init(store: :cookie,
                             key: "_app",
                             encryption_salt: "foo",
                             signing_salt: "foo")

  test "doesn't assign anything if the session is empty", %{conn: conn} do
    conn = conn
           |> get("/")
           |> AssignUser.call([])

    refute get_session(conn, :current_user)
  end

  test "doesn't assign anything if the session contains an invalid user id", %{conn: conn} do
    conn = conn(:get, "/")
					 |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
					 |> Plug.Session.call(@session)
					 |> fetch_session()

    conn = conn
           |> put_session(:current_user, Ecto.UUID.generate())
           |> AssignUser.call([])

    refute conn.assigns[:current_user]
  end

	test "assigns the user that is present in the session" do
    user = insert(:user)

    conn = conn(:get, "/")
					 |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
					 |> Plug.Session.call(@session)
					 |> fetch_session()

    conn = conn
           |> put_session(:current_user, user.id)
           |> AssignUser.call([])

    assert conn.assigns[:current_user]
	end
end
