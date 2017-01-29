defmodule Catsocket.Sockets.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @cache       Catsocket.Sockets.MessageCache
  @guid_table  Catsocket.Sockets.Users
  @rooms_table Catsocket.Sockets.Rooms

  ## Supervisor API
  def init(:ok) do
    children = [
      worker(Catsocket.Sockets.Keys, [[name: Catsocket.Sockets.Keys]]),
      worker(Catsocket.Sockets.MessageCache, [[name: @cache]]),
      worker(Catsocket.Sockets.Users, [[name: @guid_table]]),
      worker(Catsocket.Sockets.Rooms, [[name: @rooms_table]]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
