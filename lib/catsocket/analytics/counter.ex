defmodule Catsocket.Analytics.Counter do
  use GenServer

  # Public API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def incr(pid, api_key) do
    GenServer.call(pid, {:incr, api_key})
  end

  def decr(pid, api_key) do
    GenServer.call(pid, {:decr, api_key})
  end

  def get(pid, api_key) do
    GenServer.call(pid, {:get, api_key})
  end

  def delete(pid, api_key) do
    GenServer.call(pid, {:delete, api_key})
  end

  def init(_opts) do
    ets = :ets.new(__MODULE__, [:set])
    {:ok, ets}
  end

  def handle_call({:incr, api_key}, _from, ets) do
    if :ets.lookup(ets, api_key) == [] do
      :ets.insert(ets, {api_key, 1})
    else
      :ets.update_counter(ets, api_key, 1)
    end

    {:reply, :ok, ets}
  end

  def handle_call({:decr, api_key}, _from, ets) do
    :ets.update_counter(ets, api_key, -1)

    {:reply, :ok, ets}
  end

  def handle_call({:get, api_key}, _from, ets) do
    case :ets.lookup(ets, api_key) do
      [{ _, value}] ->
        {:reply, value, ets}

      [] ->
        {:reply, 0, ets}
     end
  end

  def handle_call({:delete, api_key}, _from, ets) do
    :ets.delete(ets, api_key)
    {:reply, :ok, ets}
  end
end
