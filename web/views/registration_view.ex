defmodule Catsocket.RegistrationView do
  use Catsocket.Web, :view

  def simple_form_for(changeset, action, f) do

  end

  def input(f, name, type) do
    text = case type do
      :text -> text_input(f, name, class: "form-control")
      :password -> password_input(f, name, class: "form-control")
    end

    content_tag :div, class: "form-group" do
      [
        content_tag(:label, name, for: name),
        text
      ]
    end
  end

  def submit_button(text) do
    content_tag :button, text, class: "btn btn-primary", type: "submit"
  end
end
