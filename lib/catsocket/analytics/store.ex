defmodule Catsocket.Analytics.Store do
  use GenServer

  def attach do
    GenEvent.add_handler(Catsocket.Logger, __MODULE__, [])
  end

  def init(_state) do
    table = :ets.new(__MODULE__, [:duplicate_bag])
    {:ok, table}
  end

  def handle_event({:log, event, args}, table) do
    ts = Timex.Duration.epoch(:seconds)
    :ets.insert(table, {ts, event, args})
    {:ok, table}
  end

  def handle_call(:messages, messages) do
    {:ok, Enum.reverse(messages), []}
  end

  def handle_info(:cleanup, state) do
    # TODO
    {:noreply, state}
  end


  # @interval 60*1000 # 60 seconds

  # def init(opts) do
  #   table = :ets.new(__MODULE__, [:duplicate_bag])
  #
  #   Process.send_after(self, :clear_sum, @interval)
  #   {:ok, table}
  # end
end
