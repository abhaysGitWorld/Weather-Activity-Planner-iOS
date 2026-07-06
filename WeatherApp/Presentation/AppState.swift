import Foundation

// Explicit State Modeling representing the exact operational lifecycle of the UI.
enum AppState: Equatable {
    case idle
    case searching
    case loadingWeather(cityName: String)
    case success(locationName: String, country: String, days: [DayActivities])
    case error(message: String)
}

struct DayActivities: Identifiable, Equatable {
    let id = UUID()
    let dateString: String
    let ranks: [ActivityRank]
}

struct ActivityRank: Identifiable, Equatable {
    var id: String { activityName }
    let activityName: String
    let score: Double // Scaled from 0.0 (unusable) to 1.0 (perfect condition)
}
