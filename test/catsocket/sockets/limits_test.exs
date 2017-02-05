defmodule Catsocket.Sockets.LimitsTest do
  use ExUnit.Case
  alias Catsocket.Socket.Limits

  test "it saves number of connections" do
    { :ok, pid } = Limits.start_link([paid: 3, free: 1])
    { connections, result } = Limits.increase_connection(pid, "api_key")
    assert connections == 1
    assert result == true

    { connections, result } = Limits.increase_connection(pid, "api_key")
    assert connections == 2
    assert result == false
  end
end
