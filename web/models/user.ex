defmodule Catsocket.User do
  use Catsocket.Web, :model

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  @primary_key {:id, :binary_id, autogenerate: true}
  # TODO: is this required?
  @derive {Phoenix.Param, key: :id}

  @registration_params [:email, :password, :password_confirmation]

  schema "users" do
    field :email, :string
    field :encrypted_password, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @registration_params)
    |> validate_required(@registration_params)
    |> hash_password
    # TODO: proper email validation
    |> validate_format(:email, ~r/@/)
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 7)
    |> unique_constraint(:email)
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:encrypted_password, hashpwsalt(password))
    else
      changeset
    end
  end
end
