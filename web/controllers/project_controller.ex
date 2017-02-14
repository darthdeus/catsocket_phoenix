defmodule Catsocket.ProjectController do
  use Catsocket.Web, :controller

  alias Catsocket.Project

  def index(conn, _params) do
    projects = Repo.all(Project)
    changeset = Project.changeset(%Project{})
    render(conn, "index.html", projects: projects, changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    case create_project(project_params) do
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Unable to create a new project.")
        |> render("new.html", changeset: changeset)
      _ ->
        conn
        |> put_flash(:info, "You have successfully created a new project.")
        |> redirect(to: "/projects")
    end
  end

  def show(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Ecto.Changeset.change(project, name: project.name)
    render(conn, "show.html", project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Repo.get!(Project, id)
    project = Ecto.Changeset.change(project, name: project_params["name"])

    case Repo.update(project) do
      {:ok, struct} -> 
        conn
        |> put_flash(:info, "You have successfully updated project.")
        |> redirect(to: "/projects")
      {:error, changeset} -> # Something went wrong
        conn
        |> put_flash(:error, "Unable to update project.")
        |> render("new.html", changeset: changeset)
    end
  end

  defp create_project(project_params) do
    %Project{public_key: Ecto.UUID.generate, private_key: Ecto.UUID.generate}
    |> Project.changeset(project_params)
    |> Repo.insert
  end
end
