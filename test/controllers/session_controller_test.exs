defmodule Catsocket.SessionControllerTest do
  use Catsocket.ConnCase

  alias Catsocket.User
  import Catsocket.Factory

  test "GET /login", %{conn: conn} do
    conn = get conn, "/login"
    assert html_response(conn, 200)
  end


  test "POST /login with with non-existent user", %{conn: conn} do
    invalid_params = [
      %{},
      %{email: "foo@example.com"},
      %{email: "foo@example.com", password: "foobarbaz"},
      %{email: "foo@example.com", password: "foobarbaz"}
    ]

    for params <- invalid_params do
      conn = post conn, "/login", session: params

      assert html_response(conn, 200)
      assert get_flash(conn, :error) =~ "Invalid combination"

      refute Repo.get_by(User, %{})
      refute get_session(conn, :current_user)
    end
  end

  test "POST /login with valid credentials", %{conn: conn} do
    password = "password"
    user = insert(:user, password: password, password_confirmation: password)

    params = %{
      email: user.email,
      password: password,
    }

    conn = post conn, "/login", session: params

    assert redirected_to(conn) == page_path(conn, :index)
    assert get_flash(conn, :info) =~ "You have successfully"
    assert get_session(conn, :current_user) == user.id

    assert Repo.one(User)
  end

  test "DELETE /logout removes the session", %{session_conn: conn} do
    password = "password"
    user = insert(:user, password: password, password_confirmation: password)

    conn = conn
           |> assign(:current_user, user.id)
           |> delete("/logout")

    assert redirected_to(conn) == page_path(conn, :index)
    assert get_flash(conn, :info) =~ "You were logged out"

    refute conn.assigns[:current_user]
    refute get_session(conn, :current_user)
  end
end
