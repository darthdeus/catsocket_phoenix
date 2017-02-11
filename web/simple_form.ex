defmodule Catsocket.SimpleForm do
  import Phoenix.HTML.Tag

  def simple_form_for(_changeset, _action, _f) do

  end

  def checkbox_input(f, name) do
    label = name_to_label(name)

    content_tag :div, class: "form-group" do
      content_tag :div, class: "checkbox" do
        content_tag :label, class: "boolean optional" do
          [
            content_tag(:input, "", type: "checkbox", class: "boolean optional"),
            label
          ]
        end
      end
    end
  end

  def input(f, name, type) do
    input(f, name_to_label(name), name, type)
  end

  def input(f, label, name, type) do
    text = case type do
      :text -> text_input(f, name, class: "form-control")
      :password -> password_input(f, name, class: "form-control")
    end

    error = case f.source.errors[name] do
      {err,_} -> err
      nil -> nil
    end

    content_tag :div, class: "form-group" do
      [
        content_tag(:label, label, for: name),
        text,
        content_tag(:strong, error)
      ]
    end
  end

  def submit_button(text) do
    content_tag :button, text, class: "btn btn-primary", type: "submit"
  end

  def checkbox_input(_f, name, opts) do
    content_tag :input, "", opts ++ [type: "checkbox", name: name]
  end

  def text_input(_f, name, opts) do
    content_tag :input, "", opts ++ [type: "text", name: name]
  end

  def password_input(_f, name, opts) do
    content_tag :input, "", opts ++ [type: "password", name: name]
  end

  def name_to_label(name) do
    Atom.to_string(name)
    |> String.split("_")
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join(" ")
  end
end
