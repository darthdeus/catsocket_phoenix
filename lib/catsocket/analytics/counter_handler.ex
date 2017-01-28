defmodule Catsocket.Analytics.CounterHandler do
  @behaviour :cowboy_http_handler
  alias Catsocket.Analytics.Counter

  def init(_, req, _opts) do
    {:ok, req, :undefined}
  end

  def handle(req, state) do
    {api_key, req} = :cowboy_req.qs_val("api_key", req)

    value = Counter.get(Counter, api_key)

    headers = [
      {"content-type", "text/plain"},
      {"Access-Control-Allow-Origin", "*"}
    ]
    text = inspect value

    {:ok, res} = :cowboy_req.reply(200, headers, text, req)

    {:ok, res, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end
