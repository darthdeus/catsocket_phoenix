defmodule Catsocket.Sockets.MessageCache do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def put(pid, item) do
    GenServer.call(pid, {:put, item})
  end

  def get(pid, item) do
    GenServer.call(pid, {:get, item})
  end

  def cleanup(pid, expire_in \\ 60) do
    GenServer.call(pid, {:cleanup, expire_in})
  end

  ## GenServer API

  def init([]) do
    Process.send_after self(), :timeout, 1000

    ets = :ets.new(__MODULE__, [:set])
    {:ok, ets}
  end

  def handle_call({:put, item}, _from, state) do
    time = Timex.Duration.epoch(:seconds)
    true = :ets.insert(state, {item, time})
    {:reply, :ok, state}
  end

  def handle_call({:get, item}, _from, state) do
    items = :ets.lookup(state, item)
    case items do
      [] ->
        {:reply, false, state}
      _ ->
        {:reply, true, state}
    end
  end

  def handle_call({:cleanup, expire_in}, _from, state) do
    current_time = Timex.Duration.epoch(:seconds)

    to_delete = :ets.foldl(fn ({guid, time}, acc) ->
      if time >= (current_time + expire_in) do
        [guid|acc]
      else
        acc
      end
    end, [], state)

    for guid <- to_delete, do: :ets.delete(state, guid)

    {:reply, :ok, state}
  end

  def handle_info(:timeout, state) do
    # IO.puts "received timeout 3"
    Process.send_after self(), :timeout, 1000
    {:noreply, state}
  end
end
