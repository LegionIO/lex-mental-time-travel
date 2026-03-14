# frozen_string_literal: true

module Legion
  module Extensions
    module MentalTimeTravel
      module Helpers
        class TimeTraveler
          attr_reader :journeys, :history

          def initialize
            @journeys = {}
            @history  = []
          end

          def create_journey(journey_type:, domain:, destination:, temporal_target:, perspective: :field)
            trim_journeys! if @journeys.size >= Constants::MAX_JOURNEYS
            journey = MentalJourney.new(
              journey_type:            journey_type,
              domain:                  domain,
              destination_description: destination,
              temporal_target:         temporal_target,
              perspective:             perspective
            )
            @journeys[journey.id] = journey
            journey
          end

          def add_waypoint(journey_id:, description:, temporal_distance:,
                           vividness: Constants::DEFAULT_VIVIDNESS, emotional_charge: 0.0,
                           confidence: Constants::DEFAULT_VIVIDNESS, constructed: false)
            journey = @journeys[journey_id]
            return { success: false, error: 'journey not found' } unless journey

            added = journey.add_waypoint(
              description:       description,
              temporal_distance: temporal_distance,
              vividness:         apply_distance_discount(vividness, temporal_distance),
              emotional_charge:  emotional_charge,
              confidence:        confidence,
              constructed:       constructed || randomly_confabulated?
            )
            { success: added, waypoint_count: journey.waypoints.size }
          end

          def travel(journey_id:)
            journey = @journeys[journey_id]
            return { success: false, error: 'journey not found' } unless journey

            result = journey.travel
            { success: result, state: journey.state }
          end

          def arrive(journey_id:)
            journey = @journeys[journey_id]
            return { success: false, error: 'journey not found' } unless journey

            result = journey.arrive
            { success: result, state: journey.state }
          end

          def reflect(journey_id:)
            journey = @journeys[journey_id]
            return { success: false, error: 'journey not found' } unless journey

            result = journey.reflect
            { success: result, state: journey.state, narrative_coherence: journey.narrative_coherence }
          end

          def complete_journey(journey_id:)
            journey = @journeys[journey_id]
            return { success: false, error: 'journey not found' } unless journey

            result = journey.complete
            archive_journey!(journey) if result
            { success: result, state: journey.state }
          end

          def retrospect(domain:, waypoints:)
            journey = create_journey(
              journey_type:    :retrospection,
              domain:          domain,
              destination:     "retrospective: #{domain}",
              temporal_target: waypoints.map { |w| w[:temporal_distance] || 0 }.max || 0
            )
            populate_waypoints!(journey, waypoints)
            journey.travel
            journey.arrive
            journey.reflect
            journey
          end

          def prospect(domain:, waypoints:)
            journey = create_journey(
              journey_type:    :prospection,
              domain:          domain,
              destination:     "prospective: #{domain}",
              temporal_target: waypoints.map { |w| w[:temporal_distance] || 0 }.max || 0
            )
            populate_waypoints!(journey, waypoints)
            journey.travel
            journey.arrive
            journey.reflect
            journey
          end

          def journeys_by_type(type:)
            sym = type.to_sym
            @journeys.values.select { |j| j.journey_type == sym }
          end

          def most_vivid_journeys(limit: 5)
            @journeys.values
                     .sort_by { |j| -j.aggregate_vividness }
                     .first(limit)
          end

          def emotional_arc_for(journey_id:)
            journey = @journeys[journey_id]
            return { found: false } unless journey

            { found: true, arc: journey.emotional_arc, journey_id: journey_id }
          end

          def confabulation_report
            return { total_journeys: 0, average_confabulation_rate: 0.0, rates: [] } if @journeys.empty?

            rates = @journeys.values.map { |j| { id: j.id, rate: j.confabulation_rate } }
            avg   = rates.sum { |r| r[:rate] } / rates.size
            { total_journeys: @journeys.size, average_confabulation_rate: avg, rates: rates }
          end

          def autonoetic_level
            return 0.0 if @journeys.empty?

            recent = @journeys.values.last([Constants::MAX_HISTORY, @journeys.size].min)
            return 0.0 if recent.empty?

            recent.sum(&:aggregate_vividness) / recent.size
          end

          def autonoetic_label
            level = autonoetic_level
            Constants::AUTONOETIC_LABELS.each do |range, label|
              return label if range.cover?(level)
            end
            :semantic_only
          end

          def decay_all
            @journeys.each_value(&:decay_vividness)
          end

          def to_h
            {
              journey_count:        @journeys.size,
              history_count:        @history.size,
              autonoetic_level:     autonoetic_level,
              autonoetic_label:     autonoetic_label,
              confabulation_report: confabulation_report,
              journeys:             @journeys.values.map(&:to_h)
            }
          end

          private

          def apply_distance_discount(vividness, temporal_distance)
            discount = temporal_distance.to_f * Constants::TEMPORAL_DISCOUNT
            [vividness.to_f - discount, Constants::VIVIDNESS_FLOOR].max
          end

          def randomly_confabulated?
            rand < Constants::CONSTRUCTION_ERROR_RATE
          end

          def populate_waypoints!(journey, waypoints)
            waypoints.each do |wp|
              journey.add_waypoint(
                description:       wp[:description] || '',
                temporal_distance: wp[:temporal_distance] || 0,
                vividness:         wp.fetch(:vividness, Constants::DEFAULT_VIVIDNESS),
                emotional_charge:  wp.fetch(:emotional_charge, 0.0),
                confidence:        wp.fetch(:confidence, Constants::DEFAULT_VIVIDNESS),
                constructed:       wp.fetch(:constructed, false)
              )
            end
          end

          def archive_journey!(journey)
            @history << journey.to_h
            @history.shift if @history.size > Constants::MAX_HISTORY
          end

          def trim_journeys!
            oldest_ids = @journeys.keys.first(@journeys.size - Constants::MAX_JOURNEYS + 1)
            oldest_ids.each { |id| @journeys.delete(id) }
          end
        end
      end
    end
  end
end
