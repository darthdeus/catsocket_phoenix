defmodule Catsocket.MessageCacheTest do
  use ExUnit.Case
  alias Catsocket.Sockets.MessageCache

  test "message can be cached" do
    {:ok, pid} = MessageCache.start_link

    response = MessageCache.put(pid, "olaficek")
    assert response == :ok

    response = MessageCache.get(pid, "olaficek")
    assert response == true

    response = MessageCache.get(pid, "bobik")
    assert response == false
  end

  test "messages expire" do
    {:ok, pid} = MessageCache.start_link
    response = MessageCache.put(pid, "olaficek")

    MessageCache.cleanup(pid, 0)
    response = MessageCache.get(pid, "olaficek")
    assert response == false
  end
end
