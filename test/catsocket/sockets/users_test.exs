defmodule Catsocket.UsersTest do
  use ExUnit.Case
  alias Catsocket.Sockets.Users

  test "associated guid can be fetched later" do
    {:ok, pid} = Users.start_link

    guid = "123"
    :ok = Users.associate(pid, guid, self())

    assert Users.fetch(pid, guid) == self()

    :ok = Users.remove(pid, self())
    refute Users.fetch(pid, guid)
  end

  test "when the pid dies, it's automatically disassociated" do
    {:ok, pid} = Users.start_link

    nuf = spawn fn -> :timer.sleep :infinity end

    guid = "123"
    Users.associate(pid, guid, nuf)

    :erlang.exit(nuf, :kill)

    refute Process.alive?(nuf)
    refute Users.fetch(pid, guid)
  end
end
