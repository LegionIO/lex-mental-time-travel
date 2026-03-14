# frozen_string_literal: true

RSpec.describe Legion::Extensions::MentalTimeTravel::Helpers::TemporalWaypoint do
  subject(:waypoint) do
    described_class.new(
      index:             0,
      description:       'Standing in childhood kitchen',
      temporal_distance: 180.0,
      perspective:       :field,
      vividness:         0.7,
      emotional_charge:  0.6,
      confidence:        0.8,
      constructed:       false
    )
  end

  describe '#initialize' do
    it 'sets index' do
      expect(waypoint.index).to eq(0)
    end

    it 'sets description' do
      expect(waypoint.description).to eq('Standing in childhood kitchen')
    end

    it 'sets temporal_distance as float' do
      expect(waypoint.temporal_distance).to be_within(0.001).of(180.0)
    end

    it 'sets perspective' do
      expect(waypoint.perspective).to eq(:field)
    end

    it 'sets vividness' do
      expect(waypoint.vividness).to be_within(0.001).of(0.7)
    end

    it 'sets emotional_charge' do
      expect(waypoint.emotional_charge).to be_within(0.001).of(0.6)
    end

    it 'sets confidence' do
      expect(waypoint.confidence).to be_within(0.001).of(0.8)
    end

    it 'sets constructed_detail' do
      expect(waypoint.constructed_detail).to be(false)
    end

    it 'clamps vividness to VIVIDNESS_FLOOR minimum' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10, vividness: 0.0)
      expect(wp.vividness).to be_within(0.001).of(
        Legion::Extensions::MentalTimeTravel::Helpers::Constants::VIVIDNESS_FLOOR
      )
    end

    it 'clamps vividness to 1.0 maximum' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10, vividness: 2.0)
      expect(wp.vividness).to be_within(0.001).of(1.0)
    end

    it 'clamps emotional_charge to -1.0 minimum' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10, emotional_charge: -5.0)
      expect(wp.emotional_charge).to be_within(0.001).of(-1.0)
    end

    it 'clamps emotional_charge to 1.0 maximum' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10, emotional_charge: 5.0)
      expect(wp.emotional_charge).to be_within(0.001).of(1.0)
    end

    it 'clamps confidence to 0.0 minimum' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10, confidence: -1.0)
      expect(wp.confidence).to be_within(0.001).of(0.0)
    end

    it 'defaults perspective to :field for unknown values' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10, perspective: :unknown)
      expect(wp.perspective).to eq(:field)
    end

    it 'accepts :observer perspective' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10, perspective: :observer)
      expect(wp.perspective).to eq(:observer)
    end
  end

  describe '#emotionally_enhanced?' do
    it 'returns true when charge is >= 0.5' do
      expect(waypoint.emotionally_enhanced?).to be(true)
    end

    it 'returns true when charge is <= -0.5' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10, emotional_charge: -0.7)
      expect(wp.emotionally_enhanced?).to be(true)
    end

    it 'returns false when charge is below 0.5 absolute' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10, emotional_charge: 0.3)
      expect(wp.emotionally_enhanced?).to be(false)
    end
  end

  describe '#distant?' do
    it 'returns true when temporal_distance > 365' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 400)
      expect(wp.distant?).to be(true)
    end

    it 'returns false when temporal_distance <= 365' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 365)
      expect(wp.distant?).to be(false)
    end
  end

  describe '#decay_vividness!' do
    it 'reduces vividness by VIVIDNESS_DECAY' do
      original = waypoint.vividness
      waypoint.decay_vividness!
      expected = original - Legion::Extensions::MentalTimeTravel::Helpers::Constants::VIVIDNESS_DECAY
      expect(waypoint.vividness).to be_within(0.001).of(expected)
    end

    it 'does not decay below VIVIDNESS_FLOOR' do
      wp = described_class.new(index: 0, description: 'test', temporal_distance: 10,
                               vividness: Legion::Extensions::MentalTimeTravel::Helpers::Constants::VIVIDNESS_FLOOR)
      100.times { wp.decay_vividness! }
      expect(wp.vividness).to be_within(0.001).of(
        Legion::Extensions::MentalTimeTravel::Helpers::Constants::VIVIDNESS_FLOOR
      )
    end
  end

  describe '#to_h' do
    subject(:hash) { waypoint.to_h }

    it 'includes index' do
      expect(hash[:index]).to eq(0)
    end

    it 'includes description' do
      expect(hash[:description]).to eq('Standing in childhood kitchen')
    end

    it 'includes temporal_distance' do
      expect(hash[:temporal_distance]).to be_within(0.001).of(180.0)
    end

    it 'includes perspective' do
      expect(hash[:perspective]).to eq(:field)
    end

    it 'includes vividness' do
      expect(hash[:vividness]).to be_within(0.001).of(0.7)
    end

    it 'includes emotional_charge' do
      expect(hash[:emotional_charge]).to be_within(0.001).of(0.6)
    end

    it 'includes confidence' do
      expect(hash[:confidence]).to be_within(0.001).of(0.8)
    end

    it 'includes constructed_detail' do
      expect(hash[:constructed_detail]).to be(false)
    end

    it 'includes emotionally_enhanced' do
      expect(hash[:emotionally_enhanced]).to be(true)
    end

    it 'includes distant' do
      expect(hash[:distant]).to be(false)
    end
  end
end
