defmodule Catsocket.ProjectControllerTest do
  use Catsocket.ConnCase

  alias Catsocket.Project

  test "create & show", %{conn: conn} do
    conn = conn
           |> post("/projects", project: %{"name" => "Haley"})

    assert redirected_to(conn) == project_path(conn, :index)
    assert get_flash(conn, :info) =~ "You have successfully created"

    project = Repo.get_by(Project, name: "Haley")

    assert project
    assert project.public_key
    assert project.private_key

    conn = conn
           |> get(project_path(conn, :show, project.id))

    assert html_response(conn, 200)
  end

  test "update", %{conn: conn} do
    old_project = Repo.insert! %Project{name: "Lulu"}

    conn = conn
           |> put("/projects/#{old_project.id}", project: %{"name" => "Olaf"})

    assert redirected_to(conn) == project_path(conn, :index)
    assert get_flash(conn, :info) =~ "You have successfully updated"

    project = Repo.get_by(Project, name: "Olaf")
    assert project
    assert old_project.public_key == project.public_key
    assert old_project.private_key == project.private_key
  end

   test "delete", %{conn: conn} do
     project = Repo.insert! %Project{name: "Lulu"}

     conn = delete conn, project_path(conn, :delete, project)
     assert redirected_to(conn) == project_path(conn, :index)
     refute Repo.get(Project, project.id)
   end
end
