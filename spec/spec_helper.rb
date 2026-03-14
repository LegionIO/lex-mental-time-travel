# frozen_string_literal: true

require 'legion/extensions/mental_time_travel/version'
require 'legion/extensions/mental_time_travel/helpers/constants'
require 'legion/extensions/mental_time_travel/helpers/temporal_waypoint'
require 'legion/extensions/mental_time_travel/helpers/mental_journey'
require 'legion/extensions/mental_time_travel/helpers/time_traveler'
require 'legion/extensions/mental_time_travel/runners/mental_time_travel'
require 'legion/extensions/mental_time_travel/client'

module Legion
  module Extensions
    module Helpers
      module Lex; end
    end
  end
end

module Legion
  module Logging
    def self.method_missing(*); end
    def self.respond_to_missing?(*) = true
  end
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
