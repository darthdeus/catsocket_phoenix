defmodule Catsocket.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Catsocket.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Catsocket.Router.Helpers

      # The default endpoint for testing
      @endpoint Catsocket.Endpoint
    end
  end


  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Catsocket.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Catsocket.Repo, {:shared, self()})
    end

    # TODO: clean this up a bit
    session = Plug.Session.init(store: :cookie,
                                key: "_app",
                                encryption_salt: "foo",
                                signing_salt: "foo")

    conn = Phoenix.ConnTest.build_conn(:get, "/")
					 |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
					 |> Plug.Session.call(session)
					 |> Plug.Conn.fetch_session()

    {:ok, conn: Phoenix.ConnTest.build_conn(), session_conn: conn}
  end
end
