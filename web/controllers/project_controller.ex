defmodule Catsocket.ProjectController do
  use Catsocket.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
