defmodule Catsocket.MessageCacheTest do
  use ExUnit.Case
  alias Catsocket.Sockets.MessageCache

  test "message can be cached" do
    {:ok, pid} = MessageCache.start_link

    response = MessageCache.put(pid, "olaficek")
    assert response == :ok

    response = MessageCache.get(pid, "olaficek")
    assert response

    response = MessageCache.get(pid, "bobik")
    refute response
  end

  test "messages expire" do
    {:ok, pid} = MessageCache.start_link

    MessageCache.put(pid, "olaficek")
    MessageCache.cleanup(pid, 0)

    refute MessageCache.get(pid, "olaficek")
  end
end
