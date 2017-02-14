defmodule Catsocket.Project do
  use Catsocket.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "projects" do
    field :name, :string
    field :public_key, Ecto.UUID
    field :private_key, Ecto.UUID

    timestamps()

    belongs_to :user, Catsocket.User
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :public_key, :private_key])
    |> validate_required([:name])
  end
end
