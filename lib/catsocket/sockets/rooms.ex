defmodule Catsocket.Sockets.Rooms do
  use GenServer

  alias Catsocket.Sockets.Users

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  ## Public API

  def join(pid, api_key, room, user) do
    if room == nil, do: throw {:invalid, room}

    GenServer.call(pid, {:join, room_name(api_key, room), user})
  end

  def leave(pid, api_key, room, user) do
    if room == nil, do: throw {:invalid, room}

    GenServer.call(pid, {:leave, room_name(api_key, room), user})
  end

  def members(pid, api_key, room) do
    if room == nil, do: throw {:invalid, room}

    GenServer.call(pid, {:members, room_name(api_key, room)})
  end

  def broadcast(pid, api_key, room, text) do
    names = members(pid, api_key, room)

    message = %{
      action: "message",
      id: Ecto.UUID.generate(),
      timestamp: Timex.Duration.epoch(:milliseconds),
      data: %{
        message: text,
        room: room,
      }
    }

    json = Poison.encode!(message)

    for name <- names do
      # IO.puts "broadcast to #{name} json #{json}"
      Users.broadcast(Users, name, json)
    end
  end

  def remove_user(pid, user) do
    GenServer.call(pid, {:remove_user, user})
  end

  ## GenServer API

  def init(:ok) do
    ets = :ets.new(__MODULE__, [:bag])
    {:ok, ets}
  end

  def handle_call({:join, room, user}, _from, ets) do
    true = :ets.insert(ets, {room, user})
    {:reply, :ok, ets}
  end

  def handle_call({:leave, room, user}, _from, ets) do
    true = :ets.match_delete(ets, {room, user})
    {:reply, :ok, ets}
  end

  def handle_call({:members, room}, _from, ets) do
    members = :ets.match_object(ets, {room, :_})
    names = for {_, name} <- members, do: name

    {:reply, names, ets}
  end

  def handle_call({:remove_user, user}, _from, ets) do
    :ets.match_delete(ets, {:_, user})
    {:reply, :ok, ets}
  end

  def room_name(api_key, room) do
    "#{api_key}:#{room}"
  end

  # TODO - implement gen server which keeps a set of all users
  #        in a given room ... or maybe run each room as a separate
  #        process, so that way they could be easily distributed? :)

end
