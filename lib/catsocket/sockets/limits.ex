defmodule Catsocket.Socket.Limits do
  use GenServer
  def start_link(opts \\ [paid: 1, free: 1]) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def increase_connection(pid, api_key) do
    GenServer.call(pid, { :increase, api_key })
  end

  # GenServer API
  def init([paid: paid, free: free]) do
    ets = :ets.new(__MODULE__, [:set])
    { :ok, { ets, paid, free } }
  end

  def handle_call({:increase, api_key}, _from, state) do
    { ets, paid_limit, free_limit } = state

    case :ets.lookup(ets, api_key) do
      [] ->
        :ets.insert(ets, {api_key, false, 1, 0})
        {:reply, {1, true}, state}

      [{api_key, is_paid, conns, messages}] ->
        new_conns = conns + 1
        :ets.insert(ets, {api_key, is_paid, new_conns, messages})

        is_valid_conn = if is_paid do
          new_conns <= paid_limit
        else
          new_conns <= free_limit
        end
        {:reply, {new_conns, is_valid_conn}, state}
    end
  end
end
