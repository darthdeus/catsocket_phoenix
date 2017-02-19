defmodule Catsocket.PageView do
  use Catsocket.Web, :view

  def flashes(conn) do
    [:info, :error]
    |> Enum.map(& { &1, get_flash(conn, &1) } )
    |> Enum.filter(fn {_type, text} -> (text != nil) end)
    |> Enum.map(fn {type, text} -> { (if type == :error, do: :danger, else: type), text } end )
    |> Enum.map(fn {type, text} -> content_tag(:p, text, class: "alert alert-#{type}", role: "alert") end)
  end

  def image_tag(img, opts) do
    content_tag :img, "", src: "/images/#{img}", class: opts[:class]
  end

  def fa_icon(name, opts) do
    content_tag :i, opts[:text], class: "fa-#{name}"
  end
end
