# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module MentalTimeTravel
      module Helpers
        class MentalJourney
          attr_reader :id, :journey_type, :domain, :destination_description,
                      :temporal_target, :waypoints, :state, :perspective,
                      :created_at, :narrative_coherence

          def initialize(journey_type:, domain:, destination_description:,
                         temporal_target:, perspective: :field)
            @id                      = SecureRandom.uuid
            @journey_type            = validate_journey_type!(journey_type)
            @domain                  = domain
            @destination_description = destination_description
            @temporal_target         = temporal_target.to_f
            @perspective             = validate_perspective!(perspective)
            @waypoints               = []
            @state                   = :planning
            @created_at              = Time.now.utc
            @narrative_coherence     = 0.0
          end

          def add_waypoint(description:, temporal_distance:, vividness: Constants::DEFAULT_VIVIDNESS,
                           emotional_charge: 0.0, confidence: Constants::DEFAULT_VIVIDNESS, constructed: false)
            return false if @waypoints.size >= Constants::MAX_WAYPOINTS_PER_JOURNEY

            wp = TemporalWaypoint.new(
              index:             @waypoints.size,
              description:       description,
              temporal_distance: temporal_distance,
              perspective:       @perspective,
              vividness:         vividness,
              emotional_charge:  emotional_charge,
              confidence:        confidence,
              constructed:       constructed
            )
            @waypoints << wp
            true
          end

          def travel
            return false unless @state == :planning

            @state = :traveling
            true
          end

          def arrive
            return false unless @state == :traveling

            @state = :arrived
            true
          end

          def reflect
            return false unless @state == :arrived

            @state = :reflecting
            @narrative_coherence = compute_narrative_coherence
            true
          end

          def complete
            return false unless @state == :reflecting

            @state = :completed
            true
          end

          def emotional_arc
            @waypoints.map(&:emotional_charge)
          end

          def confabulation_rate
            return 0.0 if @waypoints.empty?

            constructed = @waypoints.count(&:constructed_detail)
            constructed.to_f / @waypoints.size
          end

          def aggregate_vividness
            return 0.0 if @waypoints.empty?

            @waypoints.sum(&:vividness) / @waypoints.size
          end

          def retrospective?
            @journey_type == :retrospection
          end

          def prospective?
            @journey_type == :prospection
          end

          def decay_vividness
            @waypoints.each(&:decay_vividness!)
          end

          def to_h
            {
              id:                      @id,
              journey_type:            @journey_type,
              domain:                  @domain,
              destination_description: @destination_description,
              temporal_target:         @temporal_target,
              perspective:             @perspective,
              state:                   @state,
              waypoints:               @waypoints.map(&:to_h),
              narrative_coherence:     @narrative_coherence,
              emotional_arc:           emotional_arc,
              confabulation_rate:      confabulation_rate,
              aggregate_vividness:     aggregate_vividness,
              created_at:              @created_at
            }
          end

          private

          def compute_narrative_coherence
            return 0.0 if @waypoints.empty?

            @waypoints.sum { |wp| wp.vividness * wp.confidence } / @waypoints.size
          end

          def validate_journey_type!(type)
            sym = type.to_sym
            raise ArgumentError, "invalid journey_type: #{type}" unless Constants::JOURNEY_TYPES.include?(sym)

            sym
          end

          def validate_perspective!(perspective)
            sym = perspective.to_sym
            Constants::TEMPORAL_PERSPECTIVES.include?(sym) ? sym : :field
          end
        end
      end
    end
  end
end
