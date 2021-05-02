#! /bin/sh

if test "$RAILS_ENV" = "development"
  then
    echo "Booting Zeus..."

    # Removes the previous instance if it exists
    rm -f .zeus.sock

    # Zeus manages RAILS_ENV internally so we need to unset it
    export RAILS_ENV=""

    # & disowns the process so that we can keep running other commands
    zeus start &
fi
