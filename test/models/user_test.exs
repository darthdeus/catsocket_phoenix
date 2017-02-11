defmodule Catsocket.UserTest do
  use Catsocket.ModelCase

  alias Catsocket.User
  import Catsocket.Factory

  test "has a valid factory" do
    user = build(:user)
    assert User.changeset(user).valid?
  end

  test "changeset with invalid attributes" do
    refute User.changeset(%User{}).valid?
    refute User.changeset(%User{}, %{}).valid?
  end

  test "user's password gets hashed on save" do

  end
end
