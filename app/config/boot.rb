ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
# require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

# Zeus was not compatible with Bootsnap so when Zeus
# is used, we'll just exclude Bootsnap.
#
# Related issues:
#   - https://github.com/burke/zeus/issues/617
#   - https://github.com/burke/zeus/issues/641
require 'bootsnap/setup' unless ENV["ZEUS_MASTER_FD"]
