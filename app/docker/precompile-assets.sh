#! /bin/sh

if test "$RAILS_ENV" = "production"
  then
    echo "Precompiling assets..."
    bundle exec rake assets:precompile
fi
