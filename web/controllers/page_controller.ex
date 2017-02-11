defmodule Catsocket.PageController do
  use Catsocket.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", guid: Ecto.UUID.generate
  end

  def about(conn, _params) do
    render conn, "about.html"
  end

  def docs(conn, _params) do
    render conn, "docs.html"
  end
end
