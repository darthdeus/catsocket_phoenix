defmodule Catsocket.Socket.Limits do
  use GenServer
  def start_link(opts \\ [paid: 1, free: 1]) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def increase_connection(pid, api_key) do
    GenServer.call(pid, {:increase, api_key})
  end

  def decrease_connection(pid, api_key) do
    GenServer.call(pid, {:decrease, api_key})
  end

  def get_state(pid, api_key) do
    GenServer.call(pid, {:get_state, api_key})
  end

  def switch_to_paid(pid, api_key) do
    GenServer.call(pid, {:switch_to_paid, api_key})
  end

  # GenServer API
  def init([paid: paid, free: free]) do
    ets = :ets.new(__MODULE__, [:set])
    {:ok, {ets, paid, free}}
  end

  def handle_call({:increase, api_key}, _from, state) do
    {ets, paid_limit, free_limit} = state

    case :ets.lookup(ets, api_key) do
      [] ->
        # inserting { key = key, is_paid = false, connections = 1 and messages = 0 }
        :ets.insert(ets, {api_key, false, 1, 0})
        {:reply, {1, true}, state}

      # If there already is that api key
      [{api_key, is_paid, conns, messages}] ->
        new_conns = conns + 1
        :ets.insert(ets, {api_key, is_paid, new_conns, messages})

        is_valid_conn = if is_paid do
          # is number of connections smaller than paid plan limit? if yes, it is valid
          new_conns <= paid_limit
        else
          # is number of connections smaller than free plan limit? if yes, it is valid
          new_conns <= free_limit
        end
        # returning number of connections and if it is valid or not
        {:reply, {new_conns, is_valid_conn}, state}
    end
  end

  def handle_call({:decrease, api_key}, _from, state) do
    {ets, paid_limit, free_limit} = state

    case :ets.lookup(ets, api_key) do
      [] ->
        {:reply, {0, true}, state}
      [{api_key, is_paid, conns, messages}] ->
        new_conns = conns - 1
        :ets.insert(ets, {api_key, is_paid, new_conns, messages})

        is_valid_conn = if is_paid do
          new_conns <= paid_limit
        else
          new_conns <= free_limit
        end
        {:reply, {new_conns, is_valid_conn}, state}
    end
  end

  def handle_call({:get_state, api_key}, _from, state) do
    {ets, paid_limit, free_limit} = state

    case :ets.lookup(ets, api_key) do
      [] ->
        {:reply, {0, true}, state}
      [{_, is_paid, conns, _}] ->
        is_valid_conn = if is_paid do
          conns <= paid_limit
        else
          conns <= free_limit
        end

        {:reply, {conns, is_valid_conn, is_paid}, state}
    end
  end

  def handle_call({:switch_to_paid, api_key}, _from, state) do
    {ets, _, _} = state

    case :ets.lookup(ets, api_key) do
      [{api_key, _, conns, messages}] ->
        :ets.insert(ets, {api_key, true, conns, messages})
    end

    {:reply, :ok, state}
  end
end
