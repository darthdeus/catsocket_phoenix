defmodule Catsocket.WS.WebsocketHandler do
  @behaviour :cowboy_websocket_handler

  alias Catsocket.ClientHandler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_type, req, _opts) do
    {:ok, pid} = ClientHandler.start_link(self())
    {:ok, req, pid}
  end

  def websocket_info({:broadcast, :text, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_info({:broadcast, :binary, message}, req, state) do
    {:reply, {:binary, message}, req, state}
  end

  def websocket_info(info, req, state) do
    # TODO: log unexpected info messages
    IO.puts "info #{inspect info}"
    {:ok, req, state}
  end

  def websocket_terminate(_reason, _req, handler_pid) do
    ClientHandler.closed_connection(handler_pid)
  end

  def websocket_handle({:binary, payload}, req, handler_pid) do
    case ClientHandler.binary_message(handler_pid, {:binary, payload}) do
      {:ok, reply} ->
        {:reply, reply, req, handler_pid}

      {:error, _reason} ->
        # TODO: log error reason
        {:shutdown, req, handler_pid}
    end
  end

  def websocket_handle({:text, text}, req, handler_pid) do
    case ClientHandler.incoming_message(handler_pid, {:text, text}) do
      {:ok, reply} ->
        {:reply, reply, req, handler_pid}

      {:error, _reason} ->
        # TODO: log error reason
        {:shutdown, req, handler_pid}
    end
  end

  def websocket_handle(data, req, state) do
    # TODO: log unexpected binary messages
    IO.puts "unknown #{inspect data}"
    {:reply, {:text, "unknown message"}, req, state}
  end
end
