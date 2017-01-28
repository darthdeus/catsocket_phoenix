defmodule Catsocket.Sockets.Keys do
  use GenServer

  ## Public API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def console_room(pid, public_key) do
    GenServer.call(pid, {:get, public_key})
  end

  def get(pid, public_key) do
    private_key = GenServer.call(pid, {:get, public_key})

    if private_key != nil do
      true
    else
      false
    end
  end

  ## GenServer API

  def init(_) do
     send self, :fetch
    {:ok, []}
  end

  def handle_info(:fetch, state) do
    {:noreply, state}
    # try do
    #   response = HTTPotion.get("https://catsocket.com/keys").body
    #
    #   case Poison.decode(response) do
    #     {:ok, json} ->
    #       Process.send_after(self, :fetch, 60 * 1000)
    #       {:noreply, json}
    #
    #     {:error, msg} ->
    #       IO.puts "invalid response"
    #       IO.inspect msg
    #       {:noreply, state}
    #   end
    # catch
    #   err -> IO.puts "Failed to fetch keys #{inspect err}"
    # end
  end

  def handle_info(msg, ets) do
    IO.puts "unrecognized message #{inspect msg}"
    {:noreply, ets}
  end

  def handle_call({:get, public_key}, _from, state) do
    filtered = Enum.filter state, fn x ->
      x["public_key"] == public_key
    end

    case filtered do
      [%{"private_key" => private_key}] ->
        {:reply, private_key, state}

      _ ->
        {:reply, nil, state}
    end
  end

end
