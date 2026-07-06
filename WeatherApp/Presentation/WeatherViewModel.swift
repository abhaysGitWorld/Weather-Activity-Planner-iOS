import Foundation

class WeatherViewModel: ObservableObject {
    @Published var state: AppState = .idle
    private let network: NetworkEngine
    
    init(network: NetworkEngine = .shared) {
        self.network = network
    }
    
    func searchAndRankActivities(for cityName: String) {
        let stripped = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !stripped.isEmpty else { return }
        
        self.state = .searching
        
        // Chain step 1: Coordinate translation
        network.fetchCoordinates(for: stripped) { [weak self] locationResult in
            guard let self = self else { return }
            
            switch locationResult {
            case .failure(let error):
                DispatchQueue.main.sync { self.state = .error(message: error.localizedDescription) }
                
            case .success(let cityData):
                DispatchQueue.main.sync { self.state = .loadingWeather(cityName: cityData.name) }
                
                // Chain step 2: Weather metric processing
                self.network.fetch7DayForecast(lat: cityData.latitude, lon: cityData.longitude) { forecastResult in
                    switch forecastResult {
                    case .failure(let error):
                        DispatchQueue.main.sync { self.state = .error(message: error.localizedDescription) }
                        
                    case .success(let weatherData):
                        let derivedDays = self.transformForecastToRanks(weatherData)
                        DispatchQueue.main.sync {
                            self.state = .success(
                                locationName: cityData.name,
                                country: cityData.country,
                                days: derivedDays
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func transformForecastToRanks(_ response: ForecastResponse) -> [DayActivities] {
        var weeklyActivities: [DayActivities] = []
        let daily = response.daily
        
        // Loop through the 7-day array returned by the API
        for index in 0..<daily.time.count {
            guard index < daily.temperature_2m_max.count,
                  index < daily.rain_sum.count,
                  index < daily.snowfall_sum.count else { break }
            
            let structuredRanks = ActivityRanker.generateRanks(
                maxTemp: daily.temperature_2m_max[index],
                rainSum: daily.rain_sum[index],
                snowSum: daily.snowfall_sum[index]
            )
            
            weeklyActivities.append(
                DayActivities(dateString: daily.time[index], ranks: structuredRanks)
            )
        }
        return weeklyActivities
    }
}
