# frozen_string_literal: true

RSpec.describe Legion::Extensions::MentalTimeTravel::Helpers::MentalJourney do
  subject(:journey) do
    described_class.new(
      journey_type:            :retrospection,
      domain:                  'childhood',
      destination_description: 'First day of school',
      temporal_target:         3650.0,
      perspective:             :field
    )
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(journey.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets journey_type' do
      expect(journey.journey_type).to eq(:retrospection)
    end

    it 'sets domain' do
      expect(journey.domain).to eq('childhood')
    end

    it 'sets destination_description' do
      expect(journey.destination_description).to eq('First day of school')
    end

    it 'sets temporal_target' do
      expect(journey.temporal_target).to be_within(0.001).of(3650.0)
    end

    it 'sets perspective' do
      expect(journey.perspective).to eq(:field)
    end

    it 'starts in planning state' do
      expect(journey.state).to eq(:planning)
    end

    it 'starts with empty waypoints' do
      expect(journey.waypoints).to be_empty
    end

    it 'starts with zero narrative_coherence' do
      expect(journey.narrative_coherence).to be_within(0.001).of(0.0)
    end

    it 'raises ArgumentError for invalid journey_type' do
      expect do
        described_class.new(
          journey_type:            :invalid,
          domain:                  'test',
          destination_description: 'test',
          temporal_target:         10
        )
      end.to raise_error(ArgumentError, /invalid journey_type/)
    end
  end

  describe '#retrospective? / #prospective?' do
    it 'returns true for retrospective?' do
      expect(journey.retrospective?).to be(true)
    end

    it 'returns false for prospective?' do
      expect(journey.prospective?).to be(false)
    end

    context 'with prospection journey' do
      subject(:prospection) do
        described_class.new(
          journey_type:            :prospection,
          domain:                  'career',
          destination_description: '5 years ahead',
          temporal_target:         1825
        )
      end

      it 'returns false for retrospective?' do
        expect(prospection.retrospective?).to be(false)
      end

      it 'returns true for prospective?' do
        expect(prospection.prospective?).to be(true)
      end
    end
  end

  describe '#add_waypoint' do
    it 'adds a waypoint and returns true' do
      result = journey.add_waypoint(description: 'Scene 1', temporal_distance: 100)
      expect(result).to be(true)
      expect(journey.waypoints.size).to eq(1)
    end

    it 'returns false when MAX_WAYPOINTS_PER_JOURNEY reached' do
      Legion::Extensions::MentalTimeTravel::Helpers::Constants::MAX_WAYPOINTS_PER_JOURNEY.times do |i|
        journey.add_waypoint(description: "Scene #{i}", temporal_distance: i)
      end
      result = journey.add_waypoint(description: 'overflow', temporal_distance: 999)
      expect(result).to be(false)
    end

    it 'waypoint inherits journey perspective' do
      journey.add_waypoint(description: 'Scene', temporal_distance: 10)
      expect(journey.waypoints.first.perspective).to eq(:field)
    end
  end

  describe 'state machine' do
    it 'transitions planning -> traveling' do
      expect(journey.travel).to be(true)
      expect(journey.state).to eq(:traveling)
    end

    it 'returns false when travel called in wrong state' do
      journey.travel
      expect(journey.travel).to be(false)
    end

    it 'transitions traveling -> arrived' do
      journey.travel
      expect(journey.arrive).to be(true)
      expect(journey.state).to eq(:arrived)
    end

    it 'returns false when arrive called in wrong state' do
      expect(journey.arrive).to be(false)
    end

    it 'transitions arrived -> reflecting' do
      journey.travel
      journey.arrive
      expect(journey.reflect).to be(true)
      expect(journey.state).to eq(:reflecting)
    end

    it 'returns false when reflect called in wrong state' do
      expect(journey.reflect).to be(false)
    end

    it 'transitions reflecting -> completed' do
      journey.travel
      journey.arrive
      journey.reflect
      expect(journey.complete).to be(true)
      expect(journey.state).to eq(:completed)
    end

    it 'returns false when complete called in wrong state' do
      expect(journey.complete).to be(false)
    end
  end

  describe '#narrative_coherence' do
    it 'is computed after reflect' do
      journey.add_waypoint(description: 'A', temporal_distance: 10, vividness: 0.8, confidence: 0.9)
      journey.add_waypoint(description: 'B', temporal_distance: 20, vividness: 0.6, confidence: 0.7)
      journey.travel
      journey.arrive
      journey.reflect
      expect(journey.narrative_coherence).to be > 0.0
    end

    it 'remains 0.0 with no waypoints after reflect' do
      journey.travel
      journey.arrive
      journey.reflect
      expect(journey.narrative_coherence).to be_within(0.001).of(0.0)
    end
  end

  describe '#emotional_arc' do
    it 'returns array of emotional charges' do
      journey.add_waypoint(description: 'A', temporal_distance: 10, emotional_charge: -0.5)
      journey.add_waypoint(description: 'B', temporal_distance: 20, emotional_charge: 0.8)
      arc = journey.emotional_arc
      expect(arc.size).to eq(2)
      expect(arc[0]).to be_within(0.001).of(-0.5)
      expect(arc[1]).to be_within(0.001).of(0.8)
    end

    it 'returns empty array when no waypoints' do
      expect(journey.emotional_arc).to eq([])
    end
  end

  describe '#confabulation_rate' do
    it 'returns 0.0 with no waypoints' do
      expect(journey.confabulation_rate).to be_within(0.001).of(0.0)
    end

    it 'calculates fraction of constructed waypoints' do
      journey.add_waypoint(description: 'Real', temporal_distance: 10, constructed: false)
      journey.add_waypoint(description: 'Fake', temporal_distance: 20, constructed: true)
      expect(journey.confabulation_rate).to be_within(0.001).of(0.5)
    end

    it 'returns 1.0 when all waypoints are constructed' do
      journey.add_waypoint(description: 'Fake A', temporal_distance: 10, constructed: true)
      journey.add_waypoint(description: 'Fake B', temporal_distance: 20, constructed: true)
      expect(journey.confabulation_rate).to be_within(0.001).of(1.0)
    end
  end

  describe '#aggregate_vividness' do
    it 'returns 0.0 with no waypoints' do
      expect(journey.aggregate_vividness).to be_within(0.001).of(0.0)
    end

    it 'averages vividness across waypoints' do
      journey.add_waypoint(description: 'A', temporal_distance: 10, vividness: 0.8)
      journey.add_waypoint(description: 'B', temporal_distance: 20, vividness: 0.4)
      expect(journey.aggregate_vividness).to be_within(0.001).of(0.6)
    end
  end

  describe '#decay_vividness' do
    it 'decays all waypoints' do
      journey.add_waypoint(description: 'A', temporal_distance: 10, vividness: 0.8)
      before = journey.waypoints.first.vividness
      journey.decay_vividness
      expect(journey.waypoints.first.vividness).to be < before
    end
  end

  describe '#to_h' do
    subject(:hash) { journey.to_h }

    before do
      journey.add_waypoint(description: 'Scene', temporal_distance: 100, vividness: 0.7)
    end

    it 'includes id' do
      expect(hash[:id]).to eq(journey.id)
    end

    it 'includes journey_type' do
      expect(hash[:journey_type]).to eq(:retrospection)
    end

    it 'includes domain' do
      expect(hash[:domain]).to eq('childhood')
    end

    it 'includes state' do
      expect(hash[:state]).to eq(:planning)
    end

    it 'includes waypoints as array of hashes' do
      expect(hash[:waypoints]).to be_an(Array)
      expect(hash[:waypoints].first).to be_a(Hash)
    end

    it 'includes narrative_coherence' do
      expect(hash).to have_key(:narrative_coherence)
    end

    it 'includes emotional_arc' do
      expect(hash[:emotional_arc]).to be_an(Array)
    end

    it 'includes confabulation_rate' do
      expect(hash).to have_key(:confabulation_rate)
    end

    it 'includes aggregate_vividness' do
      expect(hash).to have_key(:aggregate_vividness)
    end
  end
end
