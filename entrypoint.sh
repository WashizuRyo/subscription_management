#!/bin/sh
set -e

# RailsのPIDファイルが残っていたら削除
rm -f /work/tmp/pids/server.pid

exec "$@" 