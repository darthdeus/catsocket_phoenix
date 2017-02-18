defmodule Catsocket.PageView do
  use Catsocket.Web, :view

  def flashes(conn) do
    [:info, :error]
    |> Enum.map(&get_flash(conn, &1))
    |> Enum.filter(&(&1 != nil))
    |> Enum.map(&content_tag(:p, &1, class: "alert alert-#{&1}", role: "alert"))
  end

  def image_tag(img, opts) do
    content_tag :img, "", src: "/images/#{img}", class: opts[:class]
  end

  def fa_icon(name, opts) do
    content_tag :i, opts[:text], class: "fa-#{name}"
  end
end
