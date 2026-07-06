import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var searchFieldText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Persistent City Search Field Header Control
                HStack(spacing: 12) {
                    TextField("Search city (e.g., Tokyo, Oslo)...", text: $searchFieldText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                    
                    Button(action: { viewModel.searchAndRankActivities(for: searchFieldText) }) {
                        Image(systemName: "magnifyingglass")
                            .font(.headline)
                            .padding(.horizontal, 4)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Declarative view presentation derived directly from the application state
                switch viewModel.state {
                case .idle:
                    VStack(spacing: 12) {
                        Image(systemName: "cloud.sun.hop.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        Text("Plan Your Next Adventure")
                            .font(.title2).bold()
                        Text("Search for a destination above to evaluate localized sport and sightseeing viability over the next 7 days.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.all, 40)
                    .frame(maxHeight: .infinity)
                    
                case .searching:
                    VStack(spacing: 15) {
                        ProgressView()
                        Text("Resolving geographic position records...").font(.caption).foregroundColor(.secondary)
                    }.frame(maxHeight: .infinity)
                    
                case .loadingWeather(let city):
                    VStack(spacing: 15) {
                        ProgressView()
                        Text("Evaluating 7-day parameters for \(city)...").font(.caption).foregroundColor(.secondary)
                    }.frame(maxHeight: .infinity)
                    
                case .success(let targetCity, let targetCountry, let structuredDays):
                    List {
                        Section(header: Text("Ranked Destinations for \(targetCity), \(targetCountry)")) {
                            ForEach(structuredDays) { day in
                                DisclosureGroup(day.dateString) {
                                    ForEach(day.ranks) { rank in
                                        HStack {
                                            Text(rank.activityName)
                                                .font(.body)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text(String(format: "Score: %.0f%%", rank.score * 100))
                                                .font(.callout)
                                                .bold()
                                                .foregroundColor(rank.score > 0.65 ? .green : (rank.score > 0.3 ? .orange : .red))
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                case .error(let reasonString):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text("Query Processing Failed").font(.headline)
                        Text(reasonString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationTitle("Activity Metrics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
