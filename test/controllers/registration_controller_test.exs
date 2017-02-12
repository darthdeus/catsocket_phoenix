defmodule Catsocket.RegistrationControllerTest do
  use Catsocket.ConnCase

  alias Catsocket.User

  test "GET /registration/new", %{conn: conn} do
    conn = get conn, "/registrations/new"
    assert html_response(conn, 200)
  end

  test "POST /registration with invalid params", %{conn: conn} do
    invalid_params = [
      %{},
      %{email: "foo@example.com"},
      %{email: "foo@example.com", password: "foobarbaz"},
      %{email: "foo@example.com", password: "foobarbaz", password_confirmation: "barfoobaz"}
    ]

    for params <- invalid_params do
      conn = post conn, "/registrations", user: params

      assert html_response(conn, 200)
      assert get_flash(conn, :error) =~ "Unable to complete"

      refute Repo.get_by(User, %{})
    end
  end

  test "POST /registration with valid params", %{conn: conn} do
    params = %{
      email: "foo@example.com",
      password: "foobarbaz",
      password_confirmation: "foobarbaz"
    }

    conn = post conn, "/registrations", user: params

    assert redirected_to(conn) == page_path(conn, :index)
    assert get_flash(conn, :info) =~ "You have successfully"

    assert Repo.one(User)
  end
end
