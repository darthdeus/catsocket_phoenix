defmodule CatsocketPhoenix.PageController do
  use CatsocketPhoenix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
