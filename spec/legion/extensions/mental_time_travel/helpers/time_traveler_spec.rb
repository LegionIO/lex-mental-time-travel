# frozen_string_literal: true

RSpec.describe Legion::Extensions::MentalTimeTravel::Helpers::TimeTraveler do
  subject(:traveler) { described_class.new }

  let(:retro_waypoints) do
    [
      { description: 'First memory', temporal_distance: 3650, vividness: 0.7, emotional_charge: 0.5, confidence: 0.6 },
      { description: 'Second memory', temporal_distance: 3640, vividness: 0.6, emotional_charge: 0.3, confidence: 0.7 }
    ]
  end

  let(:future_waypoints) do
    [
      { description: 'Next year', temporal_distance: 365, vividness: 0.5, emotional_charge: 0.2, confidence: 0.4 },
      { description: 'Five years', temporal_distance: 1825, vividness: 0.4, emotional_charge: 0.1, confidence: 0.3 }
    ]
  end

  describe '#create_journey' do
    it 'creates a journey and stores it' do
      journey = traveler.create_journey(
        journey_type:    :retrospection,
        domain:          'personal',
        destination:     'Childhood home',
        temporal_target: 1000
      )
      expect(journey).to be_a(Legion::Extensions::MentalTimeTravel::Helpers::MentalJourney)
      expect(traveler.journeys[journey.id]).to eq(journey)
    end

    it 'creates prospection journey' do
      journey = traveler.create_journey(
        journey_type:    :prospection,
        domain:          'career',
        destination:     'New job',
        temporal_target: 365
      )
      expect(journey.journey_type).to eq(:prospection)
    end

    it 'trims old journeys when at capacity' do
      constants = Legion::Extensions::MentalTimeTravel::Helpers::Constants
      constants::MAX_JOURNEYS.times do |i|
        traveler.create_journey(
          journey_type:    :retrospection,
          domain:          "domain_#{i}",
          destination:     "dest_#{i}",
          temporal_target: i
        )
      end
      expect(traveler.journeys.size).to eq(constants::MAX_JOURNEYS)
      traveler.create_journey(
        journey_type: :retrospection, domain: 'new', destination: 'new', temporal_target: 0
      )
      expect(traveler.journeys.size).to be <= constants::MAX_JOURNEYS
    end
  end

  describe '#add_waypoint' do
    let(:journey) do
      traveler.create_journey(
        journey_type: :retrospection, domain: 'test', destination: 'test', temporal_target: 100
      )
    end

    it 'adds a waypoint to the journey' do
      result = traveler.add_waypoint(
        journey_id:        journey.id,
        description:       'A scene',
        temporal_distance: 50
      )
      expect(result[:success]).to be(true)
      expect(result[:waypoint_count]).to eq(1)
    end

    it 'returns failure for unknown journey_id' do
      result = traveler.add_waypoint(
        journey_id:        'nonexistent-id',
        description:       'test',
        temporal_distance: 10
      )
      expect(result[:success]).to be(false)
      expect(result[:error]).to include('not found')
    end

    it 'applies temporal discount to vividness' do
      traveler.add_waypoint(
        journey_id:        journey.id,
        description:       'Distant memory',
        temporal_distance: 10,
        vividness:         0.8
      )
      wp = journey.waypoints.first
      expect(wp.vividness).to be < 0.8
    end
  end

  describe '#travel' do
    let(:journey_id) do
      traveler.create_journey(
        journey_type: :retrospection, domain: 'test', destination: 'test', temporal_target: 100
      ).id
    end

    it 'transitions journey to traveling' do
      result = traveler.travel(journey_id: journey_id)
      expect(result[:success]).to be(true)
      expect(result[:state]).to eq(:traveling)
    end

    it 'returns failure for unknown journey' do
      result = traveler.travel(journey_id: 'bad-id')
      expect(result[:success]).to be(false)
    end
  end

  describe '#arrive' do
    let(:journey_id) do
      j = traveler.create_journey(
        journey_type: :retrospection, domain: 'test', destination: 'test', temporal_target: 100
      )
      traveler.travel(journey_id: j.id)
      j.id
    end

    it 'transitions journey to arrived' do
      result = traveler.arrive(journey_id: journey_id)
      expect(result[:success]).to be(true)
      expect(result[:state]).to eq(:arrived)
    end

    it 'returns failure for unknown journey' do
      result = traveler.arrive(journey_id: 'bad-id')
      expect(result[:success]).to be(false)
    end
  end

  describe '#reflect' do
    let(:journey_id) do
      j = traveler.create_journey(
        journey_type: :retrospection, domain: 'test', destination: 'test', temporal_target: 100
      )
      j.add_waypoint(description: 'Scene', temporal_distance: 10, vividness: 0.7, confidence: 0.8)
      traveler.travel(journey_id: j.id)
      traveler.arrive(journey_id: j.id)
      j.id
    end

    it 'transitions journey to reflecting' do
      result = traveler.reflect(journey_id: journey_id)
      expect(result[:success]).to be(true)
      expect(result[:state]).to eq(:reflecting)
    end

    it 'returns narrative_coherence' do
      result = traveler.reflect(journey_id: journey_id)
      expect(result[:narrative_coherence]).to be_a(Numeric)
    end

    it 'returns failure for unknown journey' do
      result = traveler.reflect(journey_id: 'bad-id')
      expect(result[:success]).to be(false)
    end
  end

  describe '#complete_journey' do
    let(:journey_id) do
      j = traveler.create_journey(
        journey_type: :retrospection, domain: 'test', destination: 'test', temporal_target: 100
      )
      traveler.travel(journey_id: j.id)
      traveler.arrive(journey_id: j.id)
      traveler.reflect(journey_id: j.id)
      j.id
    end

    it 'transitions journey to completed and archives it' do
      result = traveler.complete_journey(journey_id: journey_id)
      expect(result[:success]).to be(true)
      expect(result[:state]).to eq(:completed)
      expect(traveler.history).not_to be_empty
    end

    it 'returns failure for unknown journey' do
      result = traveler.complete_journey(journey_id: 'bad-id')
      expect(result[:success]).to be(false)
    end
  end

  describe '#retrospect' do
    it 'creates and walks through retrospective journey' do
      journey = traveler.retrospect(domain: 'childhood', waypoints: retro_waypoints)
      expect(journey).to be_a(Legion::Extensions::MentalTimeTravel::Helpers::MentalJourney)
      expect(journey.journey_type).to eq(:retrospection)
      expect(journey.state).to eq(:reflecting)
      expect(journey.waypoints.size).to eq(2)
    end
  end

  describe '#prospect' do
    it 'creates and walks through prospective journey' do
      journey = traveler.prospect(domain: 'career', waypoints: future_waypoints)
      expect(journey).to be_a(Legion::Extensions::MentalTimeTravel::Helpers::MentalJourney)
      expect(journey.journey_type).to eq(:prospection)
      expect(journey.state).to eq(:reflecting)
      expect(journey.waypoints.size).to eq(2)
    end
  end

  describe '#journeys_by_type' do
    before do
      traveler.retrospect(domain: 'past', waypoints: retro_waypoints)
      traveler.prospect(domain: 'future', waypoints: future_waypoints)
    end

    it 'returns only retrospection journeys' do
      result = traveler.journeys_by_type(type: :retrospection)
      expect(result.all?(&:retrospective?)).to be(true)
    end

    it 'returns only prospection journeys' do
      result = traveler.journeys_by_type(type: :prospection)
      expect(result.all?(&:prospective?)).to be(true)
    end
  end

  describe '#most_vivid_journeys' do
    before do
      traveler.retrospect(domain: 'vivid', waypoints: [{ description: 'A', temporal_distance: 1, vividness: 0.9 }])
      traveler.retrospect(domain: 'dim', waypoints: [{ description: 'B', temporal_distance: 1, vividness: 0.2 }])
    end

    it 'returns journeys sorted by vividness descending' do
      vivid = traveler.most_vivid_journeys(limit: 2)
      expect(vivid.first.aggregate_vividness).to be >= vivid.last.aggregate_vividness
    end

    it 'respects the limit' do
      expect(traveler.most_vivid_journeys(limit: 1).size).to eq(1)
    end
  end

  describe '#emotional_arc_for' do
    it 'returns arc for known journey' do
      journey = traveler.retrospect(domain: 'test', waypoints: retro_waypoints)
      result = traveler.emotional_arc_for(journey_id: journey.id)
      expect(result[:found]).to be(true)
      expect(result[:arc]).to be_an(Array)
    end

    it 'returns not found for unknown journey' do
      result = traveler.emotional_arc_for(journey_id: 'bad-id')
      expect(result[:found]).to be(false)
    end
  end

  describe '#confabulation_report' do
    it 'returns empty report with no journeys' do
      report = traveler.confabulation_report
      expect(report[:total_journeys]).to eq(0)
      expect(report[:average_confabulation_rate]).to be_within(0.001).of(0.0)
    end

    it 'returns report with journeys present' do
      traveler.retrospect(domain: 'test', waypoints: retro_waypoints)
      report = traveler.confabulation_report
      expect(report[:total_journeys]).to be > 0
      expect(report[:rates]).to be_an(Array)
    end
  end

  describe '#autonoetic_level' do
    it 'returns 0.0 with no journeys' do
      expect(traveler.autonoetic_level).to be_within(0.001).of(0.0)
    end

    it 'returns average vividness across journeys' do
      traveler.retrospect(domain: 'test', waypoints: [{ description: 'A', temporal_distance: 1, vividness: 0.8 }])
      expect(traveler.autonoetic_level).to be > 0.0
    end
  end

  describe '#autonoetic_label' do
    it 'returns :semantic_only with no journeys' do
      expect(traveler.autonoetic_label).to eq(:semantic_only)
    end

    it 'returns a valid label symbol' do
      traveler.retrospect(domain: 'test', waypoints: [{ description: 'A', temporal_distance: 1, vividness: 0.9 }])
      valid_labels = %i[vivid_reliving clear_recall hazy fragmentary semantic_only]
      expect(valid_labels).to include(traveler.autonoetic_label)
    end
  end

  describe '#decay_all' do
    it 'decays all journey vividness' do
      traveler.retrospect(domain: 'test', waypoints: [{ description: 'A', temporal_distance: 1, vividness: 0.8 }])
      before_level = traveler.autonoetic_level
      traveler.decay_all
      expect(traveler.autonoetic_level).to be <= before_level
    end
  end

  describe '#to_h' do
    before { traveler.retrospect(domain: 'test', waypoints: retro_waypoints) }

    subject(:hash) { traveler.to_h }

    it 'includes journey_count' do
      expect(hash[:journey_count]).to eq(1)
    end

    it 'includes history_count' do
      expect(hash[:history_count]).to eq(0)
    end

    it 'includes autonoetic_level' do
      expect(hash).to have_key(:autonoetic_level)
    end

    it 'includes autonoetic_label' do
      expect(hash).to have_key(:autonoetic_label)
    end

    it 'includes confabulation_report' do
      expect(hash[:confabulation_report]).to be_a(Hash)
    end

    it 'includes journeys array' do
      expect(hash[:journeys]).to be_an(Array)
    end
  end
end
