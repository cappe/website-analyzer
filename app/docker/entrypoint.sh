#! /bin/sh

./docker/wait-for-services.sh
./docker/prepare-db.sh
./docker/prepare-zeus.sh
./docker/precompile-assets.sh

mkdir -p tmp/pids # Creates dir for Puma's pid files
bundle exec puma -C config/puma.rb
