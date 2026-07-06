# Weather-Activity-Planner-

# 7-Day City Weather Activity Ranker (Native iOS)

A native iOS application constructed using clean MVVM-T architectural separations to rank local activity suggestions over a 7-day period based on real-time weather analytics.

## Technical Selections
* **UI Framework:** SwiftUI (Declarative UI engine)
* **Design Pattern:** Clean Architecture + MVVM (Model-View-ViewModel)
* **Asynchronous Operations:** Standard Native Completion Escaping Blocks
* **Remote Datastores:** Free Open-Meteo REST APIs (Geocoding & Forecast Endpoints)

## State Lifecycle Engine
The UI state is managed via an explicit state model, ensuring a predictable user experience:
1. `idle`: Initial state prompting user input.
2. `searching`: Querying coordinates for the target city.
3. `loadingWeather`: Fetching weather forecast data using those coordinates.
4. `success`: Displays the ranked activity results.
5. `error`: Provides clear error feedback for network failures or invalid queries.

## Algorithmic Ranking Logic
* **Skiing:** Requires active snowfall parameters; scores improve with higher snow accumulation and lower temperatures.
* **Surfing:** Requires warm temperatures (>16°C) and completely dry conditions.
* **Outdoor Sightseeing:** Most viable during mild, clear conditions (14°C to 25°C); scores decrease linearly based on rain or snow.
* **Indoor Sightseeing:** Serves as a stable baseline recommendation that becomes highly favored during poor outdoor weather.
