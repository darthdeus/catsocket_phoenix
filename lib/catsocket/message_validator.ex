defmodule Catsocket.MessageValidator do
  def validate_message(message) do
    # TODO: conditional validation
    # if ! Map.has_key?(message, "api_key"),   do: throw {:invalid, "api_key"}
    # if ! Map.has_key?(message, "user"),      do: throw {:invalid, "user"}
    if ! Map.has_key?(message, "id"),        do: throw {:invalid, "id"}
    if ! Map.has_key?(message, "action"),    do: throw {:invalid, "action"}
    if ! Map.has_key?(message, "data"),      do: throw {:invalid, "data"}
  end

  def validate_identify(state) do
    if ! state[:identified], do: throw :unidentified
  end

  def validate_api_key(_key) do
    #  if ! Catsocket.Keys.get(Catsocket.Keys, key), do: throw :wrong_api_key
  end

  def parse(payload) do
    case Poison.decode(payload) do
      {:ok, message} ->
        if is_map(message) do
          {:ok, message}
        else
          {:error, "received something that wasn't a map: #{inspect message}"}
        end

      {:error, reason} ->
        {:error, "received invalid json: #{reason}"}
    end
  end
end
