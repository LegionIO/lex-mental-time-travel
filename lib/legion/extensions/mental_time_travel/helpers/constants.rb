# frozen_string_literal: true

module Legion
  module Extensions
    module MentalTimeTravel
      module Helpers
        module Constants
          MAX_JOURNEYS              = 50
          MAX_WAYPOINTS_PER_JOURNEY = 20
          MAX_HISTORY               = 200
          DEFAULT_VIVIDNESS         = 0.5
          VIVIDNESS_FLOOR           = 0.1
          VIVIDNESS_DECAY           = 0.015
          CONSTRUCTION_ERROR_RATE   = 0.1
          TEMPORAL_DISCOUNT         = 0.02
          EMOTIONAL_ENHANCEMENT     = 0.15

          JOURNEY_TYPES        = %i[retrospection prospection].freeze
          JOURNEY_STATES       = %i[planning traveling arrived reflecting completed].freeze
          TEMPORAL_PERSPECTIVES = %i[observer field].freeze

          AUTONOETIC_LABELS = {
            (0.8..)     => :vivid_reliving,
            (0.6...0.8) => :clear_recall,
            (0.4...0.6) => :hazy,
            (0.2...0.4) => :fragmentary,
            (..0.2)     => :semantic_only
          }.freeze
        end
      end
    end
  end
end
