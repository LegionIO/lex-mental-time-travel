# frozen_string_literal: true

module Legion
  module Extensions
    module MentalTimeTravel
      module Helpers
        class TemporalWaypoint
          attr_reader :index, :description, :temporal_distance, :perspective,
                      :vividness, :emotional_charge, :confidence, :constructed_detail

          def initialize(index:, description:, temporal_distance:, **opts)
            @index             = index
            @description       = description
            @temporal_distance = temporal_distance.to_f
            apply_opts(opts)
          end

          def emotionally_enhanced?
            @emotional_charge.abs >= 0.5
          end

          def distant?
            @temporal_distance > 365
          end

          def decay_vividness!
            @vividness = [@vividness - Constants::VIVIDNESS_DECAY, Constants::VIVIDNESS_FLOOR].max
          end

          def to_h
            {
              index:                @index,
              description:          @description,
              temporal_distance:    @temporal_distance,
              perspective:          @perspective,
              vividness:            @vividness,
              emotional_charge:     @emotional_charge,
              confidence:           @confidence,
              constructed_detail:   @constructed_detail,
              emotionally_enhanced: emotionally_enhanced?,
              distant:              distant?
            }
          end

          private

          def apply_opts(opts)
            @perspective      = resolve_perspective(opts.fetch(:perspective, :field))
            @vividness        = opts.fetch(:vividness, Constants::DEFAULT_VIVIDNESS).to_f
                                    .clamp(Constants::VIVIDNESS_FLOOR, 1.0)
            @emotional_charge = opts.fetch(:emotional_charge, 0.0).to_f.clamp(-1.0, 1.0)
            @confidence       = opts.fetch(:confidence, Constants::DEFAULT_VIVIDNESS).to_f.clamp(0.0, 1.0)
            @constructed_detail = opts.fetch(:constructed, false)
          end

          def resolve_perspective(perspective)
            sym = perspective.to_sym
            Constants::TEMPORAL_PERSPECTIVES.include?(sym) ? sym : :field
          end
        end
      end
    end
  end
end
