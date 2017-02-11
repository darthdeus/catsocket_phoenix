defmodule Catsocket.SessionController do
  use Catsocket.Web, :controller

  alias Catsocket.User

  def new(conn, _params) do
    render conn, "new.html", changeset: User.changeset(%User{})
  end
end
