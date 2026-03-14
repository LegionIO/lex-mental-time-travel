# frozen_string_literal: true

require 'legion/extensions/mental_time_travel/version'
require 'legion/extensions/mental_time_travel/helpers/constants'
require 'legion/extensions/mental_time_travel/helpers/temporal_waypoint'
require 'legion/extensions/mental_time_travel/helpers/mental_journey'
require 'legion/extensions/mental_time_travel/helpers/time_traveler'
require 'legion/extensions/mental_time_travel/runners/mental_time_travel'

module Legion
  module Extensions
    module MentalTimeTravel
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
