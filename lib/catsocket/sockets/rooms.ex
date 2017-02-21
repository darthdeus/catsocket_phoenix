defmodule Catsocket.Sockets.Rooms do
  use GenServer

  alias Catsocket.Sockets.Users

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  ## Public API

  @doc """
    Adds a user to a given room using a particular API key.
  """
  def join(pid, api_key, room, user) do
    if room == nil, do: throw {:invalid, room}

    GenServer.call(pid, {:join, room_name(api_key, room), user})
  end

  @doc """
    Removes a user from a given room
  """
  def leave(pid, api_key, room, user) do
    if room == nil, do: throw {:invalid, room}

    GenServer.call(pid, {:leave, room_name(api_key, room), user})
  end

  @doc """
    Retrieves all members of a given room
  """
  def members(pid, api_key, room) do
    if room == nil, do: throw {:invalid, room}

    GenServer.call(pid, {:members, room_name(api_key, room)})
  end

  @doc """
    Broadcasts a message to all members of a given room
  """
  def broadcast(pid, api_key, room, text) do
    GenServer.call(pid, {:broadcast, room_name(api_key, room), text})
  end

  @doc """
    Removes a user from all rooms (TODO: API key isn't needed?)
  """
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

  def handle_call({:broadcast, room, text}, _from, ets) do
    # TODO: use a broadcast constant for 3
    guid = Ecto.UUID.generate()

    rest = guid <> room <> << text :: binary >>
    # payload = << 3 :: size(1), guid :: size(288), room :: size(128), text :: binary >>
    payload = << 3 :: size(8), rest :: binary >>

    # :ets.foldl(fn ({_, name}, acc) ->
    #   Users.broadcast(Users, name, payload)
    #   :ok
    # end, :ok, ets)

    members = :ets.match_object(ets, {room, :_})
    for {_, name} <- members do
      Users.broadcast(Users, name, payload)
    end
    {:reply, :ok, ets}
  end

  def room_name(api_key, room) do
    "#{api_key}:#{room}"
  end

  # TODO - implement gen server which keeps a set of all users
  #        in a given room ... or maybe run each room as a separate
  #        process, so that way they could be easily distributed? :)

end
