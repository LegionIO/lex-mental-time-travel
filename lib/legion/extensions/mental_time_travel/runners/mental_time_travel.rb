# frozen_string_literal: true

module Legion
  module Extensions
    module MentalTimeTravel
      module Runners
        module MentalTimeTravelRunner
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_journey(journey_type:, domain:, destination:, temporal_target:, perspective: :field, **)
            Legion::Logging.debug "[mental_time_travel] create_journey type=#{journey_type} domain=#{domain}"
            journey = traveler.create_journey(
              journey_type:    journey_type,
              domain:          domain,
              destination:     destination,
              temporal_target: temporal_target,
              perspective:     perspective
            )
            { success: true, journey_id: journey.id, journey_type: journey.journey_type, state: journey.state }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def add_journey_waypoint(journey_id:, description:, temporal_distance:, **)
            Legion::Logging.debug "[mental_time_travel] add_waypoint journey=#{journey_id[0..7]}"
            traveler.add_waypoint(
              journey_id:        journey_id,
              description:       description,
              temporal_distance: temporal_distance,
              **extract_waypoint_opts(**)
            )
          end

          def travel_to(journey_id:, **)
            Legion::Logging.debug "[mental_time_travel] travel_to journey=#{journey_id[0..7]}"
            traveler.travel(journey_id: journey_id)
          end

          def arrive_at(journey_id:, **)
            Legion::Logging.debug "[mental_time_travel] arrive_at journey=#{journey_id[0..7]}"
            traveler.arrive(journey_id: journey_id)
          end

          def reflect_on(journey_id:, **)
            Legion::Logging.debug "[mental_time_travel] reflect_on journey=#{journey_id[0..7]}"
            result = traveler.reflect(journey_id: journey_id)
            Legion::Logging.debug "[mental_time_travel] narrative_coherence=#{result[:narrative_coherence]}"
            result
          end

          def complete_journey(journey_id:, **)
            Legion::Logging.debug "[mental_time_travel] complete_journey journey=#{journey_id[0..7]}"
            traveler.complete_journey(journey_id: journey_id)
          end

          def retrospect(domain:, waypoints:, **)
            Legion::Logging.debug "[mental_time_travel] retrospect domain=#{domain} waypoints=#{waypoints.size}"
            journey = traveler.retrospect(domain: domain, waypoints: waypoints)
            build_journey_result(journey)
          end

          def prospect(domain:, waypoints:, **)
            Legion::Logging.debug "[mental_time_travel] prospect domain=#{domain} waypoints=#{waypoints.size}"
            journey = traveler.prospect(domain: domain, waypoints: waypoints)
            build_journey_result(journey)
          end

          def emotional_arc(journey_id:, **)
            Legion::Logging.debug "[mental_time_travel] emotional_arc journey=#{journey_id[0..7]}"
            traveler.emotional_arc_for(journey_id: journey_id)
          end

          def confabulation_report(**)
            Legion::Logging.debug '[mental_time_travel] confabulation_report'
            { success: true }.merge(traveler.confabulation_report)
          end

          def autonoetic_status(**)
            Legion::Logging.debug '[mental_time_travel] autonoetic_status'
            {
              success:          true,
              autonoetic_level: traveler.autonoetic_level,
              autonoetic_label: traveler.autonoetic_label,
              journey_count:    traveler.journeys.size
            }
          end

          def update_mental_time_travel(**)
            Legion::Logging.debug '[mental_time_travel] update (decay tick)'
            traveler.decay_all
            { success: true, journey_count: traveler.journeys.size }
          end

          def mental_time_travel_stats(**)
            Legion::Logging.debug '[mental_time_travel] stats'
            report   = traveler.confabulation_report
            by_type  = {
              retrospection: traveler.journeys_by_type(type: :retrospection).size,
              prospection:   traveler.journeys_by_type(type: :prospection).size
            }
            {
              success:                    true,
              journey_count:              traveler.journeys.size,
              history_count:              traveler.history.size,
              autonoetic_level:           traveler.autonoetic_level,
              autonoetic_label:           traveler.autonoetic_label,
              average_confabulation_rate: report[:average_confabulation_rate],
              journeys_by_type:           by_type
            }
          end

          private

          def traveler
            @traveler ||= Helpers::TimeTraveler.new
          end

          def build_journey_result(journey)
            {
              success:             true,
              journey_id:          journey.id,
              journey_type:        journey.journey_type,
              state:               journey.state,
              narrative_coherence: journey.narrative_coherence,
              waypoint_count:      journey.waypoints.size
            }
          end

          def extract_waypoint_opts(**opts)
            {
              vividness:        opts.fetch(:vividness, Helpers::Constants::DEFAULT_VIVIDNESS),
              emotional_charge: opts.fetch(:emotional_charge, 0.0),
              confidence:       opts.fetch(:confidence, Helpers::Constants::DEFAULT_VIVIDNESS),
              constructed:      opts.fetch(:constructed, false)
            }
          end
        end
      end
    end
  end
end
