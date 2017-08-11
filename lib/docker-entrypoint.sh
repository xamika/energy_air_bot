#!/bin/sh
# https://stackoverflow.com/a/38732187/1935918
set -e

if [ -f /energy_air_bot/tmp/pids/server.pid ]; then
  rm /energy_air_bot/tmp/pids/server.pid
fi

#rails db:migrate 2>/dev/null || bundle exec rake db:setup

exec bundle exec "$@"
