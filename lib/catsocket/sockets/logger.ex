defmodule Catsocket.Sockets.Logger do
  require Logger
  alias Catsocket.Sockets.Rooms
  alias Catsocket.Sockets.Keys

  def init_metrics do
    :folsom_metrics.new_spiral(:join)
    :folsom_metrics.new_spiral(:leave)
    :folsom_metrics.new_spiral(:identify)
    :folsom_metrics.new_spiral(:broadcast)
  end

  def start_link do
    GenEvent.start_link [name: __MODULE__]
  end

  def join(api_key, guid, room) do
    :folsom_metrics.notify :join, 1
    GenEvent.notify __MODULE__, {:log, :join, {api_key, guid, room}}
    # ExStatsD.increment "backend.join"

    console_broadcast(api_key, "join", room, guid)
  end

  def leave(api_key, guid, room) do
    :folsom_metrics.notify :leave, 1
    GenEvent.notify __MODULE__, {:log, :leave, {api_key, guid, room}}
    # ExStatsD.increment "backend.leave"

    console_broadcast(api_key, "leave", room, guid)
  end

  def identify(api_key, guid) do
    :folsom_metrics.notify :identify, 1
    GenEvent.notify __MODULE__, {:log, :identify, {api_key, guid}}
    # ExStatsD.increment "backend.identify"

    console_broadcast(api_key, "identify", guid, "")
  end

  def broadcast(api_key, guid, room, message) do
    :folsom_metrics.notify :broadcast, 1
    GenEvent.notify __MODULE__, {:log, :broadcast, {api_key, guid, room, message}}
    # ExStatsD.increment "backend.broadcast"

    console_broadcast(api_key, "broadcast", room, message)
  end

  def log_stats(stats) do
    GenEvent.notify __MODULE__, {:log, :stats, stats}
  end

  def stream_stdout do
    spawn_link fn ->
      for msg <- GenEvent.stream(__MODULE__) do
        Logger.info(inspect msg)
      end
    end
  end

  defp console_broadcast(api_key, event, target, desc) do
    console_room = Keys.console_room(Keys, api_key)

    if console_room != nil do
      Rooms.broadcast(Rooms, api_key, console_room, %{
        event:  event,
        target: target,
        desc:   desc
      })
    end
  end
end
