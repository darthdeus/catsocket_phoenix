#!/bin/bash

if ! asdf | grep version; then git clone https://github.com/HashNuke/asdf.git ~/.asdf; fi

if ! asdf plugin-list | grep erlang; then
  asdf plugin-add erlang https://github.com/HashNuke/asdf-erlang.git
fi

if ! asdf plugin-list | grep elixir; then
  asdf plugin-add elixir https://github.com/HashNuke/asdf-elixir.git
fi

erlang_version=$(awk '/erlang/ { print $2 }' .tool-versions) && asdf install erlang ${erlang_version}
elixir_version=$(awk '/elixir/ { print $2 }' .tool-versions) && asdf install elixir ${elixir_version}

mix local.rebar --force
yes | mix deps.get
