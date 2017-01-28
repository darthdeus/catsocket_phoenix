defmodule Catsocket.Sockets.Users do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def associate(pid, guid, client) do
    GenServer.call(pid, {:associate, guid, client})
  end

  def fetch(pid, guid) do
    GenServer.call(pid, {:fetch, guid})
  end

  def remove(pid, client_pid) do
    GenServer.call(pid, {:remove, client_pid})
  end

  def broadcast(pid, guid, message) do
    user = fetch(pid, guid)

    if user == nil do
      # IO.puts "GUID for a process which doesn't exist anymore: #{inspect user} (pid: #{pid}, guid: #{guid})"
    else
      # TODO - check if there could be verification implemented here
      send user, {:broadcast, message}
    end
  end

  ## GenServer API

  def init(:ok) do
    ets = :ets.new(__MODULE__, [:bag])
    {:ok, ets}
  end

  def handle_call({:associate, guid, pid}, _from, ets) do
    true = :ets.insert(ets, {guid, pid})

    Process.monitor(pid)

    {:reply, :ok, ets}
  end

  def handle_call({:fetch, guid}, _from, ets) do
    case :ets.lookup(ets, guid) do
      [{^guid, pid}] ->
        {:reply, pid, ets}
      _ ->
        {:reply, nil, ets}
    end
  end

  def handle_call({:remove, pid}, _from, ets) do
    :ets.match_delete(ets, {:_, pid})
    {:reply, :ok, ets}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, ets) do
    :ets.match_delete(ets, {:_, pid})
    {:noreply, ets}
  end
end
