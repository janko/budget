require "bundler/setup"
require_relative "settings"

Dir.glob("#{__dir__}/initializers/*.rb") { |file| require file }

require_relative "loader"
