defmodule Catsocket.PasswordController do
  use Catsocket.Web, :controller
  alias Catsocket.User

  def new(conn, _params) do
    render conn, "new.html"
  end
end
