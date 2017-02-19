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
    send(state.client_pid, {:broadcast, payload})
    {:noreply, state}
  end

  def handle_call(:closed_connection, _from, state) do
    Users.remove(Users, self())
    # TODO: this is wrong, should be removing by client guid
    Rooms.remove_user(Rooms, state.guid)

    {:reply, :ok, state}
  end

  def handle_call({:incoming_message, payload}, _from, state) do
    case MessageValidator.parse(payload) do
      {:ok, message} ->
        process_message(message, state)

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def process_message(message, state) do
    try do
      MessageValidator.validate_message(message)

      if MessageCache.get(MessageCache, message["id"]) do
        # nic se nedeje, zprava byla zpracovana
        IO.puts "Message #{inspect message} already processed"

        {:reply, ack(message), state}
      else

        reply = case message["action"] do
          "identify"  ->
            handle_identify(message, state)
          "join"      ->
            MessageValidator.validate_identify(state)
            handle_join(message, state)
          "leave"     ->
            MessageValidator.validate_identify(state)
            handle_leave(message, state)
          "broadcast" ->
            MessageValidator.validate_identify(state)
            handle_broadcast(message, state)

          other -> IO.puts "invalid action #{other}"
        end

        # Catsocket.MessageCache.put(Catsocket.MessageCache, message["id"])
        reply
      end
    catch
      {:invalid, attr} ->
        error = %{error: "Missing attribute '#{attr}'"}
        json = Poison.encode!(error)
        {:reply, {:error, json}, state}

      :unidentified ->
        error = %{error: "Identify required"}
        json = Poison.encode!(error)
        {:reply, {:error, json}, state}

      :wrong_api_key ->
        error = %{error: "Api key required"}
        json = Poison.encode!(error)
        {:reply, {:error, json}, state}
    end
  end

  ## Client action handlers

  defp handle_identify(message, state) do
    MessageValidator.validate_api_key(message["api_key"])

    Users.associate(Users, message["user"], self())

    new_state = %{state | api_key:    message["api_key"],
                          guid:       message["user"],
                          identified: true}

    {:reply, {:ok, ack(message)}, new_state}
  end

  defp handle_join(message, state) do
    if ! Map.has_key?(message["data"], "room"), do: throw {:invalid, "room"}

    # IO.puts "joined"
    room = message["data"]["room"]

    Rooms.join(Rooms, state.api_key, room, state.guid)

    {:reply, {:ok, ack(message)}, state}
  end

  defp handle_leave(message, state) do
    if ! Map.has_key?(message["data"], "room"), do: throw {:invalid, "room"}

    room = message["data"]["room"]

    Rooms.leave(Rooms, state.api_key, room, state.guid)

    {:reply, {:ok, ack(message)}, state}
  end

  defp handle_broadcast(message, state) do
    # TODO - validate message length
    if ! Map.has_key?(message["data"], "room"), do: throw {:invalid, "room"}
    if ! Map.has_key?(message["data"], "message"), do: throw {:invalid, "message"}

    room = message["data"]["room"]
    text = message["data"]["message"]
    Rooms.broadcast(Rooms, state.api_key, room, text)

    {:reply, {:ok, ack(message)}, state}
  end

  ## Response helpers

  def ack(message) do
    json = Poison.encode!(build_ack(message))
    {:text, json}
  end

  defp build_ack(message) do
    %{
      id: message["id"],
      action: "ack"
    }
  end

end
