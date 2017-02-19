defmodule Catsocket.ClientHandlerTest do
  use ExUnit.Case
  alias Catsocket.ClientHandler

  test "starting up" do
    pid = ClientHandler.start_link(self())
  end
end
