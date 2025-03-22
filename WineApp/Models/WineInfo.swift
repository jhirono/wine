import Foundation

struct WineInfo: Identifiable, Codable {
    var id = UUID()
    var name: String
    var winery: String
    var region: String
    var country: String
    var vintage: String?
    var description: String
    var foodPairings: FoodPairings
    var subRegion: String?
    var grapeVarieties: String?
    var alcoholContent: String = ""
    var wineStyleType: String = ""
    var criticsScores: String = ""
    var tastingNotes: TastingNotes?
    var whenToDrinkYear: String = ""
    var decantingTime: String = ""
    
    struct TastingNotes: Codable {
        var aroma: String = ""
        var palate: String = ""
        var body: String = ""
        var finish: String = ""
    }
    
    struct FoodPairings: Codable {
        var dishes: [Dish]
        
        struct Dish: Identifiable, Codable {
            var id = UUID()
            var name: String
            var ingredientType: String
            var explanation: String
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        winery: String,
        region: String,
        country: String,
        vintage: String? = nil,
        description: String,
        foodPairings: FoodPairings = FoodPairings(dishes: []),
        subRegion: String? = nil,
        grapeVarieties: String? = nil,
        alcoholContent: String = "",
        wineStyleType: String = "",
        criticsScores: String = "",
        tastingNotes: TastingNotes? = nil,
        whenToDrinkYear: String = "",
        decantingTime: String = ""
    ) {
        self.id = id
        self.name = name
        self.winery = winery
        self.region = region
        self.country = country
        self.vintage = vintage
        self.description = description
        self.foodPairings = foodPairings
        self.subRegion = subRegion
        self.grapeVarieties = grapeVarieties
        self.alcoholContent = alcoholContent
        self.wineStyleType = wineStyleType
        self.criticsScores = criticsScores
        self.tastingNotes = tastingNotes
        self.whenToDrinkYear = whenToDrinkYear
        self.decantingTime = decantingTime
    }
    
    enum CodingKeys: String, CodingKey {
        // Standard keys
        case name = "wine_name"
        case winery = "winery_producer"
        case vintage
        case region
        case subRegion = "sub-region"
        case country
        case grapeVarieties = "grape_varieties"
        case alcoholContent = "alcohol_content"
        case wineStyleType = "wine_style_type"
        case criticsScores = "critics_scores"
        case tastingNotes = "tasting_notes"
        case whenToDrinkYear = "when_to_drink_year"
        case decantingTime = "decanting_time"
        case description
        
        // Food pairing related keys
        case foodPairings = "food_pairings"
        
        // Legacy keys for backward compatibility
        case style
        case foodPairing
        case pairing
        case pairings
        case agingPotential
        case additionalInfo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Initialize id
        self.id = UUID()
        
        // Required fields with fallbacks
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        
        // Optional fields
        self.winery = try container.decodeIfPresent(String.self, forKey: .winery) ?? ""
        self.vintage = try container.decodeIfPresent(String.self, forKey: .vintage)
        self.region = try container.decodeIfPresent(String.self, forKey: .region) ?? ""
        self.country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        self.grapeVarieties = try container.decodeIfPresent(String.self, forKey: .grapeVarieties)
        self.alcoholContent = try container.decodeIfPresent(String.self, forKey: .alcoholContent) ?? ""
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        
        // Try style or wineStyleType
        if let wineStyleType = try container.decodeIfPresent(String.self, forKey: .wineStyleType) {
            self.wineStyleType = wineStyleType
        } else if let style = try container.decodeIfPresent(String.self, forKey: .style) {
            self.wineStyleType = style
        } else {
            self.wineStyleType = ""
        }
        
        self.criticsScores = try container.decodeIfPresent(String.self, forKey: .criticsScores) ?? ""
        
        // Decode tasting notes as an object or create a default empty one
        if let tastingNotesContainer = try? container.nestedContainer(keyedBy: TastingNotes.CodingKeys.self, forKey: .tastingNotes) {
            self.tastingNotes = try TastingNotes(from: decoder)
        } else {
            self.tastingNotes = TastingNotes()
        }
        
        // Decode food pairings
        if let foodPairingsObj = try? container.decode(FoodPairings.self, forKey: .foodPairings) {
            self.foodPairings = foodPairingsObj
        } else if let foodPairingsStrings = try? container.decode([String].self, forKey: .foodPairings) {
            // Convert string array to FoodPairings object for backward compatibility
            let dishes = foodPairingsStrings.map { pairingString in
                let components = pairingString.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
                if components.count >= 2 {
                    return FoodPairings.Dish(
                        name: String(components[0].trimmingCharacters(in: .whitespaces)),
                        ingredientType: "Other",
                        explanation: String(components[1].trimmingCharacters(in: .whitespaces))
                    )
                } else {
                    return FoodPairings.Dish(
                        name: pairingString,
                        ingredientType: "Other",
                        explanation: ""
                    )
                }
            }
            self.foodPairings = FoodPairings(dishes: dishes)
        } else {
            self.foodPairings = FoodPairings(dishes: [])
        }
        
        // Get whenToDrinkYear or use agingPotential as fallback
        if let whenToDrinkYear = try container.decodeIfPresent(String.self, forKey: .whenToDrinkYear) {
            self.whenToDrinkYear = whenToDrinkYear
        } else if let agingPotential = try container.decodeIfPresent(String.self, forKey: .agingPotential) {
            self.whenToDrinkYear = agingPotential
        } else {
            self.whenToDrinkYear = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(winery, forKey: .winery)
        try container.encodeIfPresent(vintage, forKey: .vintage)
        try container.encode(region, forKey: .region)
        try container.encodeIfPresent(subRegion, forKey: .subRegion)
        try container.encode(country, forKey: .country)
        try container.encodeIfPresent(grapeVarieties, forKey: .grapeVarieties)
        try container.encode(alcoholContent, forKey: .alcoholContent)
        try container.encode(wineStyleType, forKey: .wineStyleType)
        try container.encode(criticsScores, forKey: .criticsScores)
        try container.encodeIfPresent(tastingNotes, forKey: .tastingNotes)
        try container.encode(foodPairings, forKey: .foodPairings)
        try container.encode(whenToDrinkYear, forKey: .whenToDrinkYear)
        try container.encode(decantingTime, forKey: .decantingTime)
        try container.encode(description, forKey: .description)
    }
}

// Extension for TastingNotes for Codable support
extension WineInfo.TastingNotes {
    enum CodingKeys: String, CodingKey {
        case aroma
        case palate
        case body
        case finish
    }
} 