defmodule Catsocket.RoomsTest do
  use ExUnit.Case
  alias Catsocket.Sockets.Rooms

  setup do
    {:ok, pid} = Rooms.start_link
    {:ok, pid: pid}
  end

  test "rooms start out empty", %{pid: pid} do
    assert Rooms.members(pid, "api-key", "some-non-existent-room") == []
  end

  test "join is idempotent", %{pid: pid} do
    Rooms.join(pid, "api-key", "test-room", "foo")
    Rooms.join(pid, "api-key", "test-room", "foo")
    assert Rooms.members(pid, "api-key", "test-room") == ["foo"]
  end

  test "leaving a room removes the user from the room", %{pid: pid} do
    Rooms.join(pid, "api-key", "test-room", "foo")
    assert Rooms.members(pid, "api-key", "test-room") == ["foo"]

    Rooms.leave(pid, "api-key", "test-room", "foo")
    assert Rooms.members(pid, "api-key", "test-room") == []
  end

  test "leaving a room keeps the user in the other rooms", %{pid: pid} do
    Rooms.join(pid, "api-key", "test-room-1", "foo")
    Rooms.join(pid, "api-key", "test-room-2", "foo")

    assert Rooms.members(pid, "api-key", "test-room-1") == ["foo"]
    assert Rooms.members(pid, "api-key", "test-room-2") == ["foo"]

    Rooms.leave(pid, "api-key", "test-room-1", "foo")

    assert Rooms.members(pid, "api-key", "test-room-1") == []
    assert Rooms.members(pid, "api-key", "test-room-2") == ["foo"]
  end

  test "multiple users can join a single room, leave it, and re-join", %{pid: pid} do
    Rooms.join(pid, "api-key", "test-room", "foo")
    Rooms.join(pid, "api-key", "test-room", "bar")

    assert_sorted Rooms.members(pid, "api-key", "test-room"), ["foo", "bar"]

    Rooms.leave(pid, "api-key", "test-room", "foo")
    assert Rooms.members(pid, "api-key", "test-room") == ["bar"]

    Rooms.join(pid, "api-key", "test-room", "foo")
    assert_sorted Rooms.members(pid, "api-key", "test-room"), ["foo", "bar"]

    Rooms.leave(pid, "api-key", "test-room", "foo")
    Rooms.leave(pid, "api-key", "test-room", "bar")
    assert Rooms.members(pid, "api-key", "test-room") == []
  end

  test "a user can be removed from all rooms", %{pid: pid} do
    key = "api-key"

    Rooms.join(pid, key, "test-room-1", "foo")
    Rooms.join(pid, key, "test-room-1", "bar")
    Rooms.join(pid, key, "test-room-2", "foo")

    Rooms.remove_user(pid, "foo")

    assert Rooms.members(pid, key, "test-room-1") == ["bar"]
    assert Rooms.members(pid, key, "test-room-2") == []
  end

  defp assert_sorted(a, b) do
    assert Enum.sort(a) == Enum.sort(b)
  end
end
