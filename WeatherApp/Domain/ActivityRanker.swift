import Foundation

struct ActivityRanker {
    
    static func generateRanks(maxTemp: Double, rainSum: Double, snowSum: Double) -> [ActivityRank] {
        var rawScores: [String: Double] = [:]
        
        // ==========================================
        // 1. SKIING RATING LOGIC
        // ==========================================
        if snowSum <= 0.3 {
            // No skiing if there is no fresh snow on the ground!
            rawScores["Skiing"] = 0.0
        } else {
            // If there is snow, calculate a base score from the depth
            var skiingScore = snowSum / 8.0
            
            // Give an extra 0.3 bonus if the temperature is below freezing (better snow quality)
            if maxTemp < 0.0 {
                skiingScore = skiingScore + 0.3
            }
            
            // Make sure the final score never goes above 1.0 (100%)
            if skiingScore > 1.0 {
                skiingScore = 1.0
            }
            
            rawScores["Skiing"] = skiingScore
        }
        
        // ==========================================
        // 2. SURFING RATING LOGIC
        // ==========================================
        if maxTemp <= 16.0 {
            // Too cold to surf!
            rawScores["Surfing"] = 0.0
        } else if snowSum > 0.0 {
            // Cannot surf if it is actively snowing!
            rawScores["Surfing"] = 0.0
        } else {
            // Calculate a score based on how warm it is above 16 degrees
            let extraWarmth = maxTemp - 16.0
            var surfingScore = extraWarmth / 15.0
            
            // Subtract points if it is raining while surfing
            let rainPenalty = rainSum * 0.05
            surfingScore = surfingScore - rainPenalty
            
            // Safeguard boundaries (Keep between 0% and 100%)
            if surfingScore > 1.0 { surfingScore = 1.0 }
            if surfingScore < 0.0 { surfingScore = 0.0 }
            
            rawScores["Surfing"] = surfingScore
        }
        
        // ==========================================
        // 3. OUTDOOR SIGHTSEEING LOGIC
        // ==========================================
        var outdoorScore = 0.4 // Cold/Hot baseline score
        
        // Check if the temperature is in the pleasant "sweet spot"
        if maxTemp >= 14.0 {
            if maxTemp <= 25.0 {
                outdoorScore = 1.0 // Perfect base score for nice weather
            }
        }
        
        // Rain and snow cause discomfort for walking outside
        let rainDiscomfort = rainSum * 0.25
        let snowDiscomfort = snowSum * 0.60
        let totalDiscomfort = rainDiscomfort + snowDiscomfort
        
        // Lower the score based on how bad the rain/snow is
        outdoorScore = outdoorScore - totalDiscomfort
        
        // Safeguard boundary (Cannot be lower than 0%)
        if outdoorScore < 0.0 {
            outdoorScore = 0.0
        }
        
        rawScores["Outdoor Sightseeing"] = outdoorScore
        
        // ==========================================
        // 4. INDOOR SIGHTSEEING LOGIC
        // ==========================================
        var indoorScore = 0.5 // Standard default fallback score (50%)
        
        // If it is raining heavily outside, indoor activities are much better!
        if rainSum > 1.5 {
            indoorScore = indoorScore + 0.30 // Bumps score up to 80%
        }
        
        rawScores["Indoor Sightseeing"] = indoorScore
        
        // ==========================================
        // 5. CONVERT AND SORT BY SCORE
        // ==========================================
        // Take our dictionary items, put them into a list, and sort them highest-to-lowest
        let activityList = rawScores.map { ActivityRank(activityName: $0.key, score: $0.value) }
        let sortedList = activityList.sorted(by: { $0.score > $1.score })
        
        return sortedList
    }
}
