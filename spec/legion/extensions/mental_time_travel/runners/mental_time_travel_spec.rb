# frozen_string_literal: true

RSpec.describe Legion::Extensions::MentalTimeTravel::Runners::MentalTimeTravelRunner do
  subject(:runner) do
    Legion::Extensions::MentalTimeTravel::Client.new
  end

  let(:journey_id) do
    result = runner.create_journey(
      journey_type:    :retrospection,
      domain:          'childhood',
      destination:     'First day of school',
      temporal_target: 3650
    )
    result[:journey_id]
  end

  describe '#create_journey' do
    it 'returns success with journey_id' do
      result = runner.create_journey(
        journey_type:    :retrospection,
        domain:          'personal',
        destination:     'Family vacation',
        temporal_target: 730
      )
      expect(result[:success]).to be(true)
      expect(result[:journey_id]).to be_a(String)
    end

    it 'returns journey_type and state' do
      result = runner.create_journey(
        journey_type:    :retrospection,
        domain:          'work',
        destination:     'Old job',
        temporal_target: 500
      )
      expect(result[:journey_type]).to eq(:retrospection)
      expect(result[:state]).to eq(:planning)
    end

    it 'creates prospection journey' do
      result = runner.create_journey(
        journey_type:    :prospection,
        domain:          'future',
        destination:     'Dream house',
        temporal_target: 365
      )
      expect(result[:success]).to be(true)
      expect(result[:journey_type]).to eq(:prospection)
    end

    it 'returns failure for invalid journey_type' do
      result = runner.create_journey(
        journey_type:    :invalid,
        domain:          'test',
        destination:     'test',
        temporal_target: 10
      )
      expect(result[:success]).to be(false)
      expect(result[:error]).to be_a(String)
    end
  end

  describe '#add_journey_waypoint' do
    it 'adds waypoint to existing journey' do
      result = runner.add_journey_waypoint(
        journey_id:        journey_id,
        description:       'Morning breakfast',
        temporal_distance: 3650
      )
      expect(result[:success]).to be(true)
      expect(result[:waypoint_count]).to eq(1)
    end

    it 'returns failure for unknown journey' do
      result = runner.add_journey_waypoint(
        journey_id:        'nonexistent',
        description:       'test',
        temporal_distance: 10
      )
      expect(result[:success]).to be(false)
    end
  end

  describe '#travel_to' do
    it 'transitions journey to traveling' do
      result = runner.travel_to(journey_id: journey_id)
      expect(result[:success]).to be(true)
      expect(result[:state]).to eq(:traveling)
    end

    it 'returns failure for unknown journey' do
      result = runner.travel_to(journey_id: 'bad-id')
      expect(result[:success]).to be(false)
    end
  end

  describe '#arrive_at' do
    before { runner.travel_to(journey_id: journey_id) }

    it 'transitions journey to arrived' do
      result = runner.arrive_at(journey_id: journey_id)
      expect(result[:success]).to be(true)
      expect(result[:state]).to eq(:arrived)
    end

    it 'returns failure for unknown journey' do
      result = runner.arrive_at(journey_id: 'bad-id')
      expect(result[:success]).to be(false)
    end
  end

  describe '#reflect_on' do
    before do
      runner.add_journey_waypoint(journey_id: journey_id, description: 'scene', temporal_distance: 100)
      runner.travel_to(journey_id: journey_id)
      runner.arrive_at(journey_id: journey_id)
    end

    it 'transitions journey to reflecting' do
      result = runner.reflect_on(journey_id: journey_id)
      expect(result[:success]).to be(true)
      expect(result[:state]).to eq(:reflecting)
    end

    it 'includes narrative_coherence' do
      result = runner.reflect_on(journey_id: journey_id)
      expect(result[:narrative_coherence]).to be_a(Numeric)
    end

    it 'returns failure for unknown journey' do
      result = runner.reflect_on(journey_id: 'bad-id')
      expect(result[:success]).to be(false)
    end
  end

  describe '#complete_journey' do
    before do
      runner.travel_to(journey_id: journey_id)
      runner.arrive_at(journey_id: journey_id)
      runner.reflect_on(journey_id: journey_id)
    end

    it 'transitions journey to completed' do
      result = runner.complete_journey(journey_id: journey_id)
      expect(result[:success]).to be(true)
      expect(result[:state]).to eq(:completed)
    end

    it 'returns failure for unknown journey' do
      result = runner.complete_journey(journey_id: 'bad-id')
      expect(result[:success]).to be(false)
    end
  end

  describe '#retrospect' do
    let(:waypoints) do
      [
        { description: 'Scene one', temporal_distance: 500, vividness: 0.7, emotional_charge: 0.4 },
        { description: 'Scene two', temporal_distance: 490, vividness: 0.6, emotional_charge: 0.2 }
      ]
    end

    it 'returns success with journey details' do
      result = runner.retrospect(domain: 'childhood', waypoints: waypoints)
      expect(result[:success]).to be(true)
      expect(result[:journey_type]).to eq(:retrospection)
      expect(result[:waypoint_count]).to eq(2)
    end

    it 'returns reflecting state' do
      result = runner.retrospect(domain: 'childhood', waypoints: waypoints)
      expect(result[:state]).to eq(:reflecting)
    end

    it 'includes narrative_coherence' do
      result = runner.retrospect(domain: 'childhood', waypoints: waypoints)
      expect(result[:narrative_coherence]).to be_a(Numeric)
    end
  end

  describe '#prospect' do
    let(:waypoints) do
      [
        { description: 'Future scene', temporal_distance: 365, vividness: 0.5, emotional_charge: 0.3 }
      ]
    end

    it 'returns success with prospection journey' do
      result = runner.prospect(domain: 'career', waypoints: waypoints)
      expect(result[:success]).to be(true)
      expect(result[:journey_type]).to eq(:prospection)
    end

    it 'returns reflecting state' do
      result = runner.prospect(domain: 'career', waypoints: waypoints)
      expect(result[:state]).to eq(:reflecting)
    end
  end

  describe '#emotional_arc' do
    before do
      runner.add_journey_waypoint(
        journey_id: journey_id, description: 'sad scene', temporal_distance: 100, emotional_charge: -0.5
      )
      runner.add_journey_waypoint(
        journey_id: journey_id, description: 'happy scene', temporal_distance: 90, emotional_charge: 0.8
      )
    end

    it 'returns arc for known journey' do
      result = runner.emotional_arc(journey_id: journey_id)
      expect(result[:found]).to be(true)
      expect(result[:arc].size).to eq(2)
    end

    it 'returns not found for unknown journey' do
      result = runner.emotional_arc(journey_id: 'bad-id')
      expect(result[:found]).to be(false)
    end
  end

  describe '#confabulation_report' do
    it 'returns success true' do
      result = runner.confabulation_report
      expect(result[:success]).to be(true)
    end

    it 'returns total_journeys' do
      result = runner.confabulation_report
      expect(result).to have_key(:total_journeys)
    end

    it 'returns average_confabulation_rate' do
      result = runner.confabulation_report
      expect(result).to have_key(:average_confabulation_rate)
    end
  end

  describe '#autonoetic_status' do
    it 'returns success true' do
      result = runner.autonoetic_status
      expect(result[:success]).to be(true)
    end

    it 'returns autonoetic_level' do
      result = runner.autonoetic_status
      expect(result[:autonoetic_level]).to be_a(Numeric)
    end

    it 'returns autonoetic_label' do
      result = runner.autonoetic_status
      valid = %i[vivid_reliving clear_recall hazy fragmentary semantic_only]
      expect(valid).to include(result[:autonoetic_label])
    end

    it 'returns journey_count' do
      result = runner.autonoetic_status
      expect(result[:journey_count]).to be_a(Integer)
    end
  end

  describe '#update_mental_time_travel' do
    it 'returns success true' do
      result = runner.update_mental_time_travel
      expect(result[:success]).to be(true)
    end

    it 'returns journey_count' do
      result = runner.update_mental_time_travel
      expect(result[:journey_count]).to be_a(Integer)
    end
  end

  describe '#mental_time_travel_stats' do
    before do
      runner.retrospect(
        domain:    'past',
        waypoints: [{ description: 'scene', temporal_distance: 100, vividness: 0.7 }]
      )
      runner.prospect(
        domain:    'future',
        waypoints: [{ description: 'scene', temporal_distance: 365, vividness: 0.5 }]
      )
    end

    it 'returns success true' do
      result = runner.mental_time_travel_stats
      expect(result[:success]).to be(true)
    end

    it 'returns journey_count' do
      result = runner.mental_time_travel_stats
      expect(result[:journey_count]).to eq(2)
    end

    it 'returns history_count' do
      result = runner.mental_time_travel_stats
      expect(result[:history_count]).to be_a(Integer)
    end

    it 'returns autonoetic_level' do
      result = runner.mental_time_travel_stats
      expect(result[:autonoetic_level]).to be_a(Numeric)
    end

    it 'returns autonoetic_label' do
      result = runner.mental_time_travel_stats
      expect(result[:autonoetic_label]).to be_a(Symbol)
    end

    it 'returns journeys_by_type breakdown' do
      result = runner.mental_time_travel_stats
      expect(result[:journeys_by_type][:retrospection]).to eq(1)
      expect(result[:journeys_by_type][:prospection]).to eq(1)
    end

    it 'returns average_confabulation_rate' do
      result = runner.mental_time_travel_stats
      expect(result[:average_confabulation_rate]).to be_a(Numeric)
    end
  end
end
