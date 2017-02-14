defmodule Catsocket.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :string
      # TODO: null false, default generate
      add :public_key, :uuid
      add :private_key, :uuid
      add :user_id, references(:users, type: :uuid)

      timestamps()
    end

  end
end
