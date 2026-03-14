# lex-mental-time-travel

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-mental-time-travel`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::MentalTimeTravel`

## Purpose

Autonoetic consciousness and temporal self-projection for LegionIO agents. Enables the agent to construct retrospective journeys (reliving past events) and prospective journeys (imagining future states) with waypoints. Each waypoint has a vividness score that decays with temporal distance and includes a random confabulation probability (10% chance of introducing a false detail). Tracks autonoetic level — the agent's phenomenal sense of "mental time travel."

## Gem Info

- **Require path**: `legion/extensions/mental_time_travel`
- **Ruby**: >= 3.4
- **License**: MIT
- **Registers with**: `Legion::Extensions::Core`

## File Structure

```
lib/legion/extensions/mental_time_travel/
  version.rb
  helpers/
    constants.rb      # Journey types, vividness params, autonoetic labels
    time_traveler.rb  # TimeTraveler class with journey lifecycle
  runners/
    mental_time_travel.rb  # Runner module (named MentalTimeTravelRunner)

spec/
  legion/extensions/mental_time_travel/
    helpers/
      constants_spec.rb
      time_traveler_spec.rb
    runners/mental_time_travel_spec.rb
  spec_helper.rb
```

## Key Constants

```ruby
MAX_JOURNEYS              = 50
MAX_WAYPOINTS_PER_JOURNEY = 20
VIVIDNESS_FLOOR           = 0.1
VIVIDNESS_DECAY           = 0.015   # vividness reduction per temporal distance unit
CONSTRUCTION_ERROR_RATE   = 0.1     # 10% probability of confabulation per waypoint
TEMPORAL_DISCOUNT         = 0.02    # additional vividness decay per distance step

JOURNEY_TYPES = %i[retrospection prospection]

AUTONOETIC_LABELS = {
  (0.8..)     => :vivid,
  (0.6...0.8) => :clear,
  (0.4...0.6) => :hazy,
  (0.2...0.4) => :fragmented,
  (..0.2)     => :dreamlike
}
```

## Helpers

### `Helpers::TimeTraveler` (class)

Central journey manager with full lifecycle and vividness modeling.

Journey data structure:
```ruby
{
  id:           String (UUID),
  type:         Symbol,         # :retrospection or :prospection
  destination:  String,         # temporal destination description
  context:      Hash,           # additional context
  state:        Symbol,         # :forming / :traveling / :arrived / :reflecting / :complete
  waypoints:    Array<Hash>,    # { description:, vividness:, confabulated:, distance: }
  autonoetic_level: Float,      # average vividness across waypoints
  created_at:   Time
}
```

| Method | Description |
|---|---|
| `create_journey(type:, destination:, context:)` | creates journey in :forming state; enforces MAX_JOURNEYS |
| `add_waypoint(journey_id:, description:, distance:)` | appends waypoint; applies distance discount + random confabulation check |
| `travel(journey_id)` | transitions :forming -> :traveling |
| `arrive(journey_id)` | transitions :traveling -> :arrived |
| `reflect(journey_id)` | transitions :arrived -> :reflecting |
| `complete(journey_id)` | transitions :reflecting -> :complete |
| `retrospect(destination:, waypoints:, context:)` | convenience: create + add waypoints + travel + arrive for retrospection |
| `prospect(destination:, waypoints:, context:)` | convenience: same for prospection |
| `confabulation_report(journey_id:)` | lists waypoints flagged as confabulated |
| `autonoetic_level(journey_id:)` | average vividness across all waypoints |
| `autonoetic_label(level)` | :vivid / :clear / :hazy / :fragmented / :dreamlike |
| `decay_all` | decrements vividness on all journey waypoints by VIVIDNESS_DECAY; removes below VIVIDNESS_FLOOR |

Vividness calculation per waypoint:
```
vividness = 1.0 - (distance * TEMPORAL_DISCOUNT)
vividness = [vividness, VIVIDNESS_FLOOR].max
# plus random confabulation flag if rand < CONSTRUCTION_ERROR_RATE
```

## Runners

Module: `Legion::Extensions::MentalTimeTravel::Runners::MentalTimeTravelRunner`

Note: The runner module is named `MentalTimeTravelRunner`, not `MentalTimeTravel`.

Private state: `@traveler` (memoized `TimeTraveler` instance).

| Runner Method | Parameters | Description |
|---|---|---|
| `create_journey` | `type:, destination:, context: {}` | Create a new temporal journey |
| `add_journey_waypoint` | `journey_id:, description:, distance: 1` | Add a waypoint to a journey |
| `travel_to` | `journey_id:` | Transition to traveling state |
| `arrive_at` | `journey_id:` | Transition to arrived state |
| `reflect_on` | `journey_id:` | Transition to reflecting state |
| `complete_journey` | `journey_id:` | Complete the journey |
| `retrospect` | `destination:, waypoints:, context: {}` | Convenience: full retrospection journey |
| `prospect` | `destination:, waypoints:, context: {}` | Convenience: full prospection journey |
| `emotional_arc` | `journey_id:` | Vividness trajectory across waypoints |
| `confabulation_report` | `journey_id:` | Waypoints flagged as confabulated |
| `autonoetic_status` | (none) | Most recent journey's autonoetic level and label |
| `update_mental_time_travel` | (none) | Decay all journey vividness values |
| `mental_time_travel_stats` | (none) | Journey count, by type, avg autonoetic level |

## Integration Points

- **lex-memory**: retrospective journeys draw on episodic memory traces; callers retrieve traces from lex-memory and describe them as waypoints.
- **lex-dream**: the `dream_reflection` phase can trigger retrospective journeys to consolidate emotionally significant episodes.
- **lex-narrative-identity**: temporal journey waypoints become episodes in the agent's narrative identity arc.
- **lex-metacognition**: `MentalTimeTravel` is listed under `:cognition` capability category.

## Development Notes

- Runner module is named `MentalTimeTravelRunner` — this is an anomaly compared to other LEX runners which match the extension name. When referencing the module, use the full path `Runners::MentalTimeTravelRunner`.
- Confabulation is a random event (10% per waypoint) simulating memory construction errors. It is purely stochastic — there is no semantic analysis of waypoint content.
- `decay_all` removes waypoints below VIVIDNESS_FLOOR but does not remove entire journeys. A journey can persist with all waypoints at floor vividness.
- `emotional_arc` returns a simple array of vividness values per waypoint in insertion order; there is no valence dimension — "emotional arc" reflects vividness, not positive/negative affect.
- `autonoetic_level` is the mean of all waypoint vividness values. A journey with many confabulated waypoints will have lower autonoetic level.
- No actor; `update_mental_time_travel` is called manually or via tick cycle.
