#! /bin/sh

echo "Preparing DB..."

# If database exists, migrate. Otherwise, setup
bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:setup

echo "DB ready!"
