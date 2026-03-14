# frozen_string_literal: true

require 'legion/extensions/mental_time_travel/helpers/constants'
require 'legion/extensions/mental_time_travel/helpers/temporal_waypoint'
require 'legion/extensions/mental_time_travel/helpers/mental_journey'
require 'legion/extensions/mental_time_travel/helpers/time_traveler'
require 'legion/extensions/mental_time_travel/runners/mental_time_travel'

module Legion
  module Extensions
    module MentalTimeTravel
      class Client
        include Runners::MentalTimeTravelRunner

        attr_reader :traveler

        def initialize(traveler: nil, **)
          @traveler = traveler || Helpers::TimeTraveler.new
        end
      end
    end
  end
end
