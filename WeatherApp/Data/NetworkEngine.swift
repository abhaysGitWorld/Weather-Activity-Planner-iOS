import Foundation

// API Response Decoding Structs mapped directly to Open-Meteo Schema formats
struct GeocodingResponse: Decodable {
    let results: [GeocodingCity]?
}

struct GeocodingCity: Decodable {
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
}

struct ForecastResponse: Decodable {
    let daily: DailyTimeline
    
    struct DailyTimeline: Decodable {
        let time: [String]
        let temperature_2m_max: [Double]
        let rain_sum: [Double]
        let snowfall_sum: [Double]
    }
}

class NetworkEngine {
    static let shared = NetworkEngine()
    private init() {}
    
    /// Contacts Open-Meteo Geocoding platform to map text queries into numeric coordinates
    func fetchCoordinates(for cityName: String, completion: @escaping (Result<GeocodingCity, Error>) -> Void) {
        let cleanName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cityName
        let urlString = "https://open-meteo.com\(cleanName)&count=1&language=en&format=json"
        
        guard let url = URL(urlString: urlString) else {
            completion(.failure(NSError(domain: "NetworkEngine", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid City URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(NSError(domain: "NetworkEngine", code: 404, userInfo: nil))); return }
            
            do {
                let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
                if let firstMatch = decoded.results?.first {
                    completion(.success(firstMatch))
                } else {
                    completion(.failure(NSError(domain: "NetworkEngine", code: 404, userInfo: [NSLocalizedDescriptionKey: "No cities found matching that text search query."])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Queries the primary weather data engine for historical/future atmospheric values
    func fetch7DayForecast(lat: Double, lon: Double, completion: @escaping (Result<ForecastResponse, Error>) -> Void) {
        let urlString = "https://open-meteo.com\(lat)&longitude=\(lon)&daily=temperature_2m_max,rain_sum,snowfall_sum&timezone=auto"
        
        guard let url = URL(urlString: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(ForecastResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
