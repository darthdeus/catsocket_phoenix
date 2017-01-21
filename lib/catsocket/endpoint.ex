defmodule Catsocket.Endpoint do
  use Phoenix.Endpoint, otp_app: :catsocket

  socket "/socket", Catsocket.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :catsocket, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_catsocket_key",
    signing_salt: "8A9YjIc8"

  plug Catsocket.Router
end

defmodule Catsocket.SimpleForm do
  defmacro __using__(_) do
    quote do
      use Phoenix.HTML

      def input(name) do
        content_tag :div, class: "form-group" do
          [
            content_tag(:p, "hello")
          ]
        end
      end
    end
  end
end
