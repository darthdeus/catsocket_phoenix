defmodule Catsocket.StatsCollector do
  use GenServer

  ## Public API


  @doc """
  Target specifies from whom the statistics should be collected.
  The `target` process must response to a :stats call
  """
  def start_link(target, opts \\ []) do
    GenServer.start_link(__MODULE__, [target], opts)
  end

  ## GenServer API
  def init(target) do
    send self(), :poll
    {:ok, target}
  end

  def handle_info(:poll, target) do
    Process.send_after self(), :poll, 10 * 1000
    response = GenServer.call(target, :stats)

    {:noreply, target}
  end

end
