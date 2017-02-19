defmodule Catsocket.ClientHandler do
  use GenServer

  alias Catsocket.MessageValidator
  alias Catsocket.Sockets.Users
  alias Catsocket.Sockets.Rooms
  alias Catsocket.Sockets.MessageCache

  @doc """
    Starts a new client handler for a given client PID
  """
  def start_link(client_pid) do
    GenServer.start_link(__MODULE__, client_pid, [])
  end

  @doc """
    Handles all cleanup for a given client
  """
  def closed_connection(pid) do
    GenServer.call(pid, :closed_connection)
    :ok
  end

  @doc """
    Handles an incoming message
  """
  def incoming_message(pid, payload) do
    GenServer.call(pid, {:incoming_message, payload})
  end

  def binary_message(pid, payload) do
    GenServer.call(pid, {:binary_message, payload})
  end

  ### GenServer callbacks

  def init(client_pid) do
    initial_state = %{
      identified: false,
      api_key:    nil,
      guid:       nil,
      client_pid: client_pid
    }

    {:ok, initial_state}
  end

  def handle_info({:broadcast, payload}, state) do
    send(state.client_pid, {:broadcast, :binary, payload})
    {:noreply, state}
  end

  def handle_call(:closed_connection, _from, state) do
    Users.remove(Users, self())
    # TODO: this is wrong, should be removing by client guid
    Rooms.remove_user(Rooms, state.guid)

    {:reply, :ok, state}
  end

  @identify  0
  @join      1
  @leave     2
  @broadcast 3
  @ack       4

  @room_len  128
  @guid_len  288

  def handle_call({:binary_message, payload}, _from, state) do
    << code :: size(8), msg_id :: size(@guid_len), data :: binary >> = payload

    case code do
      @identify ->
        << api_key :: size(@guid_len), user :: size(@guid_len) >> = data
        handle_identify(msg_id, api_key, user, state)

      @join ->
        << room :: size(@room_len) >> = data
        handle_join(msg_id, room, state)

      @leave ->
        << room :: size(@room_len) >> = data
        handle_leave(msg_id, room, state)

      @broadcast ->
        << room :: size(@room_len), rest :: binary >> = data
        handle_broadcast(msg_id, room, rest, state)
    end
  end

  ## Client action handlers

  defp handle_identify(msg_id, api_key, user, state) do
    Users.associate(Users, user, self())

    new_state = %{state | api_key:    api_key,
                          guid:       user,
                          identified: true}

    {:reply, {:ok, ack(msg_id)}, new_state}
  end

  defp handle_join(msg_id, room, state) do
    Rooms.join(Rooms, state.api_key, room, state.guid)

    {:reply, {:ok, ack(msg_id)}, state}
  end

  defp handle_leave(msg_id, room, state) do
    Rooms.leave(Rooms, state.api_key, room, state.guid)

    {:reply, {:ok, ack(msg_id)}, state}
  end

  defp handle_broadcast(msg_id, room, payload, state) do
    Rooms.broadcast(Rooms, state.api_key, room, payload)

    {:reply, {:ok, ack(msg_id)}, state}
  end

  ## Response helpers

  def ack(msg_id) do
    {:binary, << @ack :: size(8), msg_id :: size(@guid_len) >>}
  end
end
