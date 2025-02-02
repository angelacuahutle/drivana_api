# config/boot.rb

require 'logger'  # Add this line at the top

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
# ... rest of the file ...