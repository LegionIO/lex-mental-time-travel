# lex-mental-time-travel

Autonoetic temporal self-projection for LegionIO agents. Part of the LegionIO cognitive architecture extension ecosystem (LEX).

## What It Does

`lex-mental-time-travel` enables an agent to project itself backward (retrospection) and forward (prospection) in time by constructing journeys with waypoints. Each waypoint's vividness decays with temporal distance. A 10% confabulation rate introduces realistic memory construction errors. The agent's autonoetic level — its sense of mentally reliving or pre-living events — is derived from average waypoint vividness.

Key capabilities:

- **Two journey types**: retrospection (reliving past) and prospection (imagining future)
- **Vividness modeling**: decays with temporal distance, floors at 0.1
- **Confabulation**: 10% random probability of a false waypoint detail
- **State machine**: forming -> traveling -> arrived -> reflecting -> complete
- **Autonoetic labels**: vivid / clear / hazy / fragmented / dreamlike

## Installation

Add to your Gemfile:

```ruby
gem 'lex-mental-time-travel'
```

Or install directly:

```
gem install lex-mental-time-travel
```

## Usage

```ruby
require 'legion/extensions/mental_time_travel'

client = Legion::Extensions::MentalTimeTravel::Client.new

# Quick retrospective journey
result = client.retrospect(
  destination: 'last deployment incident',
  waypoints: [
    { description: 'deploy triggered', distance: 3 },
    { description: 'error rate spiked', distance: 2 },
    { description: 'rollback executed', distance: 1 }
  ]
)

# Quick prospective journey
result = client.prospect(
  destination: 'next release cycle',
  waypoints: [
    { description: 'feature freeze', distance: 1 },
    { description: 'staging deploy', distance: 2 },
    { description: 'production release', distance: 3 }
  ]
)
journey_id = result[:journey][:id]

# Check for confabulated waypoints
client.confabulation_report(journey_id: journey_id)

# Check autonoetic level
client.autonoetic_status
# => { level: 0.72, label: :clear, journey_id: "..." }

# Stats
client.mental_time_travel_stats
```

## Runner Methods

| Method | Description |
|---|---|
| `create_journey` | Create a new temporal journey |
| `add_journey_waypoint` | Add a waypoint to a journey |
| `travel_to` | Transition to traveling state |
| `arrive_at` | Transition to arrived state |
| `reflect_on` | Transition to reflecting state |
| `complete_journey` | Complete the journey |
| `retrospect` | Convenience: full retrospection journey in one call |
| `prospect` | Convenience: full prospection journey in one call |
| `emotional_arc` | Vividness trajectory across waypoints |
| `confabulation_report` | Waypoints flagged as confabulated |
| `autonoetic_status` | Most recent journey's autonoetic level and label |
| `update_mental_time_travel` | Decay all journey vividness values |
| `mental_time_travel_stats` | Journey count, by type, avg autonoetic level |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
