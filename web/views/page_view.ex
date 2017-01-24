defmodule Catsocket.PageView do
  use Catsocket.Web, :view

  def image_tag(img, opts) do
    content_tag :img, "", src: "/images/#{img}", class: opts[:class]
  end

  def fa_icon(name, opts) do
    content_tag :i, opts[:text], class: "fa-#{name}"
  end
end
