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

  test "password_confirmation is required to match the password" do
    assert User.changeset(%User{}, %{
                            password: "1234567890"
                          }).errors[:password_confirmation]

    assert User.changeset(%User{}, %{
                            password: "1234567890",
                            password_confirmation: "0987654321"
                          }).errors[:password_confirmation]

    refute User.changeset(%User{}, %{
                            password: "1234567890",
                            password_confirmation: "1234567890"
                          }).errors[:password_confirmation]
  end

  test "user's password gets hashed and isn't stored in the database" do
    user = User.changeset(build(:user))
    assert user.data.encrypted_password
    assert user.valid?

    inserted = Repo.insert!(user)

    found = Repo.get!(User, inserted.id)

    refute found.password
    refute found.password_confirmation
  end
end
