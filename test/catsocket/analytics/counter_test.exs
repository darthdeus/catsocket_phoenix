defmodule Catsocket.Analytics.CounterTest do
  use ExUnit.Case
  alias Catsocket.Analytics.Counter

  test "initializes the counter" do
    {:ok, pid} = Counter.start_link
    response = Counter.incr(pid, "Lulinka")
    assert response == :ok
  end

  test "increases the counter" do
    {:ok, pid} = Counter.start_link
    Counter.incr(pid, "Lulinka")
    Counter.incr(pid, "Lulinka")
    Counter.incr(pid, "Lulinka")
    response = Counter.get(pid, "Lulinka")
    assert response == 3
  end

  test "decreases the counter" do
    {:ok, pid} = Counter.start_link
    Counter.incr(pid, "Lulinka")
    Counter.incr(pid, "Lulinka")
    Counter.decr(pid, "Lulinka")
    response = Counter.get(pid, "Lulinka")
    assert response == 1
  end

  test "deletes the counter" do
    {:ok, pid} = Counter.start_link
    Counter.incr(pid, "Olaficek")
    Counter.delete(pid, "Olaficek")

    response = Counter.get(pid, "Olaficek")
    assert response == 0
  end
end
