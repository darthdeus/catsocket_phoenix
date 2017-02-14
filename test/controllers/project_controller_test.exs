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
    conn = conn
           |> post("/projects", project: %{"name" => "Lulu"})

    old_project = Repo.get_by(Project, name: "Lulu")

    conn = conn
           |> put("/projects/#{old_project.id}", project: %{"name" => "Olaf"})

    assert redirected_to(conn) == project_path(conn, :index)
    assert get_flash(conn, :info) =~ "You have successfully updated"

    project = Repo.get_by(Project, name: "Olaf")
    assert project
    assert old_project.public_key == project.public_key
    assert old_project.private_key == project.private_key
  end


  # alias Catsocket.Project
  # @valid_attrs %{name: "some content", private_key: "7488a646-e31f-11e4-aace-600308960662", public_key: "7488a646-e31f-11e4-aace-600308960662"}
  # @invalid_attrs %{}
  #
  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, project_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Listing projects"
  # end
  #
  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, project_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New project"
  # end
  #
  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, project_path(conn, :create), project: @valid_attrs
  #   assert redirected_to(conn) == project_path(conn, :index)
  #   assert Repo.get_by(Project, @valid_attrs)
  # end
  #
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, project_path(conn, :create), project: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New project"
  # end
  #
  # test "shows chosen resource", %{conn: conn} do
  #   project = Repo.insert! %Project{}
  #   conn = get conn, project_path(conn, :show, project)
  #   assert html_response(conn, 200) =~ "Show project"
  # end
  #
  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, project_path(conn, :show, -1)
  #   end
  # end
  #
  # test "renders form for editing chosen resource", %{conn: conn} do
  #   project = Repo.insert! %Project{}
  #   conn = get conn, project_path(conn, :edit, project)
  #   assert html_response(conn, 200) =~ "Edit project"
  # end
  #
  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   project = Repo.insert! %Project{}
  #   conn = put conn, project_path(conn, :update, project), project: @valid_attrs
  #   assert redirected_to(conn) == project_path(conn, :show, project)
  #   assert Repo.get_by(Project, @valid_attrs)
  # end
  #
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   project = Repo.insert! %Project{}
  #   conn = put conn, project_path(conn, :update, project), project: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit project"
  # end
  #
  # test "deletes chosen resource", %{conn: conn} do
  #   project = Repo.insert! %Project{}
  #   conn = delete conn, project_path(conn, :delete, project)
  #   assert redirected_to(conn) == project_path(conn, :index)
  #   refute Repo.get(Project, project.id)
  # end
end
