defmodule Catsocket.Sockets.LimitsTest do
  use ExUnit.Case
  alias Catsocket.Socket.Limits

  test "it increases number of connections" do
    { :ok, pid } = Limits.start_link([paid: 3, free: 1])
    { connections, result } = Limits.increase_connection(pid, "api_key")
    assert connections == 1
    assert result == true

    { connections, result } = Limits.increase_connection(pid, "api_key")
    assert connections == 2
    assert result == false
  end

  test "it descreases number of connection" do
    { :ok, pid } = Limits.start_link([paid: 3, free: 1])
    Limits.increase_connection(pid, "api_key")
    { connections, result } = Limits.decrease_connection(pid, "api_key")
    assert connections == 0
    assert result == true
  end

  test "it gets state of connections" do
    { :ok, pid } = Limits.start_link([paid: 3, free: 1])
    Limits.increase_connection(pid, "api_key")
    Limits.increase_connection(pid, "api_key")
    Limits.increase_connection(pid, "api_key")
    Limits.increase_connection(pid, "api_key")
    { _connections, result, _is_paid } = Limits.get_state(pid, "api_key")
    assert result == false
  end

  test "it switches to paid plan" do
    { :ok, pid } = Limits.start_link([paid: 3, free: 1])
    Limits.increase_connection(pid, "api_key")
    Limits.increase_connection(pid, "api_key")
    { _connections, result, is_paid } = Limits.get_state(pid, "api_key")
    assert result == false
    assert is_paid == false

    Limits.switch_to_paid(pid, "api_key")
    { _connections, result, is_paid } = Limits.get_state(pid, "api_key")
    assert result == true
    assert is_paid == true
  end
end
