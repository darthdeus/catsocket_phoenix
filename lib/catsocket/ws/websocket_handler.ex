defmodule Catsocket.WS.WebsocketHandler do
  @behaviour :cowboy_websocket_handler

  # alias Catsocket.Sockets.Users

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(type, req, opts) do
    {:ok, req, %{identified: false, api_key: nil, guid: nil}}
  end

  def websocket_terminate(reason, _req, _state) do
    IO.puts "connection closed with reason #{inspect reason}"
    Catsocket.Sockets.Users.remove(Catsocket.Sockets.Users, self())
    Catsocket.Sockets.Rooms.remove_user(Catsocket.Sockets.Rooms, self())

    :ok
  end

  def websocket_info({:broadcast, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_info(info, req, state) do
    IO.puts "info #{inspect info}"
    {:ok, req, state}
  end

  def websocket_handle({:text, text}, req, state) do
    case Poison.decode(text) do
      {:ok, message} ->
        if is_map(message) do
          # IO.puts "received #{inspect message}"
          process_message message, req, state
        else
          IO.puts "received something that wasn't a map: #{inspect message}"
          {:shutdown, req, state}
        end

      {:error, reason} ->
        IO.puts "invalid message received: #{inspect reason}"
        {:shutdown, req, state}
    end
  end

  def websocket_handle(data, req, state) do
    IO.puts "unknown #{inspect data}"
    {:reply, {:text, "unknown message"}, req, state}
  end

  def validate_message(message) do
    if ! Map.has_key?(message, "api_key"),   do: throw {:invalid, "api_key"}
    if ! Map.has_key?(message, "user"),      do: throw {:invalid, "user"}
    if ! Map.has_key?(message, "id"),        do: throw {:invalid, "id"}
    if ! Map.has_key?(message, "timestamp"), do: throw {:invalid, "timestamp"}
    if ! Map.has_key?(message, "action"),    do: throw {:invalid, "action"}
    if ! Map.has_key?(message, "data"),      do: throw {:invalid, "data"}
  end

  def validate_identify(state) do
    if ! state[:identified], do: throw :unidentified
  end

  def validate_api_key(_key) do
    #  if ! Catsocket.Keys.get(Catsocket.Keys, key), do: throw :wrong_api_key
  end

  def process_message(message, req, state) do
    try do
      validate_message(message)
      validate_api_key(message["api_key"])

      if Catsocket.Sockets.MessageCache.get(Catsocket.Sockets.MessageCache, message["id"]) do
        # nic se nedeje, zprava byla zpracovana
        IO.puts "Message #{inspect message} already processed"

        {:reply, ack(message), req, state}
      else

        reply = case message["action"] do
          "identify"  ->
            handle_identify(message, req, state)
          "join"      ->
            validate_identify(state)
            handle_join(message, req, state)
          "leave"     ->
            validate_identify(state)
            handle_leave(message, req, state)
          "broadcast" ->
            validate_identify(state)
            handle_broadcast(message, req, state)

          other -> IO.puts "invalid action #{other}"
        end

        # Catsocket.MessageCache.put(Catsocket.MessageCache, message["id"])
        reply
      end
    catch
      {:invalid, attr} ->
        error = %{error: "Missing attribute '#{attr}'"}
        json = Poison.encode!(error)
        {:reply, {:text, json}, req, state}

      :unidentified ->
        error = %{error: "Identify required"}
        json = Poison.encode!(error)
        {:reply, {:text, json}, req, state}

      :wrong_api_key ->
        error = %{error: "Api key required"}
        json = Poison.encode!(error)
        {:reply, {:text, json}, req, state}
    end
  end

  ## Client action handlers

  defp handle_identify(message, req, state) do
    Catsocket.Sockets.Users.associate(Catsocket.Sockets.Users, message["user"], self())

    {:reply, ack(message), req, %{state | api_key: message["api_key"], guid: message["user"], identified: true}}
  end

  defp handle_join(message, req, state) do
    if ! Map.has_key?(message["data"], "room"), do: throw {:invalid, "room"}

    room = message["data"]["room"]

    Catsocket.Sockets.Rooms.join(Catsocket.Sockets.Rooms, message["api_key"], room, state[:guid])

    {:reply, ack(message), req, state}
  end

  defp handle_leave(message, req, state) do
    if ! Map.has_key?(message["data"], "room"), do: throw {:invalid, "room"}

    room = message["data"]["room"]

    Catsocket.Sockets.Rooms.leave(Catsocket.Sockets.Rooms, message["api_key"], room, state[:guid])

    {:reply, ack(message), req, state}
  end

  defp handle_broadcast(message, req, state) do
    # TODO - validate message length
    if ! Map.has_key?(message["data"], "room"), do: throw {:invalid, "room"}
    if ! Map.has_key?(message["data"], "message"), do: throw {:invalid, "message"}

    room = message["data"]["room"]
    text = message["data"]["message"]
    Catsocket.Sockets.Rooms.broadcast(Catsocket.Sockets.Rooms, message["api_key"], room, text)

    {:reply, ack(message), req, state}
  end

  ## Response helpers

  def ack(message) do
    json = Poison.encode!(build_ack(message))
    {:text, json}
  end

  defp build_ack(message) do
    %{
      id: message["id"],
      data: %{},
      action: "ack",
      timestamp: message["timestamp"]
    }
  end
end
