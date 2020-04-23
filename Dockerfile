FROM node:8-alpine

RUN apk add nodejs yarn python make g++ libsass-dev elixir
COPY mix.exs mix.lock package.json yarn.lock ./
RUN yes | mix deps.get
RUN yarn
RUN mix deps.update postgrex
RUN mix local.rebar --force

CMD ["ash"]
