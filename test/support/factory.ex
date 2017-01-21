defmodule Catsocket.Factory do
  use ExMachina.Ecto, repo: Catsocket.Repo

  alias Catsocket.User

  def user_factory do
    User.changeset(%User{}, %{
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "password",
      password_confirmation: "password"
    })
    |> Ecto.Changeset.apply_changes()
  end
end
