defmodule Catsocket.WS.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = if Mix.env == :test do
      []
    else
      [worker(Catsocket.WS.CowboyServer, [:ok])]
    end

    supervise(children, strategy: :one_for_one)
  end
end
