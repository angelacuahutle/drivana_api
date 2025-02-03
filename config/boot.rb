# config/boot.rb

# Load Ruby’s built-in Logger first.
require 'logger'

# Patch ActiveSupport so LoggerThreadSafeLevel::Logger is defined early.
module ActiveSupport
  module LoggerThreadSafeLevel
    unless const_defined?(:Logger)
      # Directly assign Ruby’s global Logger
      Logger = ::Logger
    end
  end
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
#require 'bundler/setup'  Set up gems listed in the Gemfile.

# Comment out Bootsnap for now
# require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

require 'bundler/setup' # Set up gems listed in the Gemfile.
# ... rest of the file ...