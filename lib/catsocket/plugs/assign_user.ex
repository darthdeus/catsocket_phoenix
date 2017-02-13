defmodule Catsocket.Plugs.AssignUser do
  import Plug.Conn

  alias Catsocket.Repo
  alias Catsocket.User

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :current_user)

    if user_id do
      case Repo.get(User, user_id) do
        nil  -> assign(conn, :current_user, nil)
        user -> assign(conn, :current_user, user)
      end
    else
      assign(conn, :current_user, nil)
    end
  end
end
