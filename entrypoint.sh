#!/bin/bash
set -e

# 마이그레이션 먼저 실행
bundle exec rails db:migrate

# 전달된 명령 실행(예: rails server)
exec "$@" 