defmodule Catsocket.RegistrationController do
  use Catsocket.Web, :controller
  alias Catsocket.User

  def new(conn, _params) do
    render conn, "new.html", changeset: User.changeset(%User{})
  end

  def create(_conn, _params) do
  end
end
