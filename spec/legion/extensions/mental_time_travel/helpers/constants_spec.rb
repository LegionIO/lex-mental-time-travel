# frozen_string_literal: true

RSpec.describe Legion::Extensions::MentalTimeTravel::Helpers::Constants do
  it 'defines MAX_JOURNEYS' do
    expect(described_class::MAX_JOURNEYS).to eq(50)
  end

  it 'defines MAX_WAYPOINTS_PER_JOURNEY' do
    expect(described_class::MAX_WAYPOINTS_PER_JOURNEY).to eq(20)
  end

  it 'defines MAX_HISTORY' do
    expect(described_class::MAX_HISTORY).to eq(200)
  end

  it 'defines DEFAULT_VIVIDNESS' do
    expect(described_class::DEFAULT_VIVIDNESS).to eq(0.5)
  end

  it 'defines VIVIDNESS_FLOOR' do
    expect(described_class::VIVIDNESS_FLOOR).to eq(0.1)
  end

  it 'defines VIVIDNESS_DECAY' do
    expect(described_class::VIVIDNESS_DECAY).to be_within(0.001).of(0.015)
  end

  it 'defines CONSTRUCTION_ERROR_RATE' do
    expect(described_class::CONSTRUCTION_ERROR_RATE).to be_within(0.001).of(0.1)
  end

  it 'defines TEMPORAL_DISCOUNT' do
    expect(described_class::TEMPORAL_DISCOUNT).to be_within(0.001).of(0.02)
  end

  it 'defines EMOTIONAL_ENHANCEMENT' do
    expect(described_class::EMOTIONAL_ENHANCEMENT).to be_within(0.001).of(0.15)
  end

  it 'defines JOURNEY_TYPES as frozen array' do
    expect(described_class::JOURNEY_TYPES).to eq(%i[retrospection prospection])
    expect(described_class::JOURNEY_TYPES).to be_frozen
  end

  it 'defines JOURNEY_STATES' do
    expect(described_class::JOURNEY_STATES).to include(:planning, :traveling, :arrived, :reflecting, :completed)
    expect(described_class::JOURNEY_STATES).to be_frozen
  end

  it 'defines TEMPORAL_PERSPECTIVES' do
    expect(described_class::TEMPORAL_PERSPECTIVES).to eq(%i[observer field])
    expect(described_class::TEMPORAL_PERSPECTIVES).to be_frozen
  end

  describe 'AUTONOETIC_LABELS' do
    let(:labels) { described_class::AUTONOETIC_LABELS }

    it 'maps vivid range to :vivid_reliving' do
      matching = labels.find { |range, _| range.cover?(0.9) }
      expect(matching&.last).to eq(:vivid_reliving)
    end

    it 'maps clear range to :clear_recall' do
      matching = labels.find { |range, _| range.cover?(0.7) }
      expect(matching&.last).to eq(:clear_recall)
    end

    it 'maps mid range to :hazy' do
      matching = labels.find { |range, _| range.cover?(0.5) }
      expect(matching&.last).to eq(:hazy)
    end

    it 'maps low range to :fragmentary' do
      matching = labels.find { |range, _| range.cover?(0.3) }
      expect(matching&.last).to eq(:fragmentary)
    end

    it 'maps very low range to :semantic_only' do
      matching = labels.find { |range, _| range.cover?(0.1) }
      expect(matching&.last).to eq(:semantic_only)
    end
  end
end
