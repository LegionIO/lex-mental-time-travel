# frozen_string_literal: true

RSpec.describe Legion::Extensions::MentalTimeTravel::Client do
  subject(:client) { described_class.new }

  it 'exposes the traveler' do
    expect(client.traveler).to be_a(Legion::Extensions::MentalTimeTravel::Helpers::TimeTraveler)
  end

  it 'accepts an injected traveler' do
    custom_traveler = Legion::Extensions::MentalTimeTravel::Helpers::TimeTraveler.new
    c = described_class.new(traveler: custom_traveler)
    expect(c.traveler).to be(custom_traveler)
  end

  it 'includes the runner module' do
    expect(client).to respond_to(:create_journey)
    expect(client).to respond_to(:retrospect)
    expect(client).to respond_to(:prospect)
    expect(client).to respond_to(:autonoetic_status)
    expect(client).to respond_to(:confabulation_report)
    expect(client).to respond_to(:mental_time_travel_stats)
  end

  it 'two clients do not share state' do
    client_a = described_class.new
    client_b = described_class.new
    client_a.retrospect(
      domain:    'test',
      waypoints: [{ description: 'scene', temporal_distance: 100 }]
    )
    expect(client_b.mental_time_travel_stats[:journey_count]).to eq(0)
  end
end
