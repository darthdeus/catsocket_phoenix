defmodule Catsocket.WS.CowboyServer do
  def router do
    [
      {
        :_,
        [
          {"/b/ws", Catsocket.WS.WebsocketHandler, []}
        ]
      }
    ]
  end

  def start_link(:ok) do
    Plug.Adapters.Cowboy.http __MODULE__, [], [port: 9000, dispatch: router()]
  end
end
