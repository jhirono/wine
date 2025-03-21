import Foundation

struct WineInfo: Identifiable, Codable {
    var id = UUID()
    var name: String
    var winery: String?
    var vintage: String?
    var region: String?
    var subRegion: String?
    var country: String = ""
    var grapeVarieties: String?
    var alcoholContent: String = ""
    var wineStyleType: String = ""
    var criticsScores: String = ""
    var tastingNotes: TastingNotes?
    var foodPairings: FoodPairings?
    var whenToDrinkYear: String = ""
    
    struct TastingNotes: Codable {
        var aroma: String = ""
        var palate: String = ""
        var body: String = ""
        var finish: String = ""
    }
    
    struct FoodPairings: Codable {
        var dishes: [Dish] = []
        
        struct Dish: Codable, Identifiable {
            var id = UUID()
            var name: String
            var ingredientType: String
            var explanation: String
            
            enum CodingKeys: String, CodingKey {
                case name
                case ingredientType = "ingredient_type"
                case explanation
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        winery: String? = nil,
        vintage: String? = nil,
        region: String? = nil,
        subRegion: String? = nil,
        country: String = "",
        grapeVarieties: String? = nil,
        alcoholContent: String = "",
        wineStyleType: String = "",
        criticsScores: String = "",
        tastingNotes: TastingNotes? = nil,
        foodPairings: FoodPairings? = nil,
        whenToDrinkYear: String = ""
    ) {
        self.id = id
        self.name = name
        self.winery = winery
        self.vintage = vintage
        self.region = region
        self.subRegion = subRegion
        self.country = country
        self.grapeVarieties = grapeVarieties
        self.alcoholContent = alcoholContent
        self.wineStyleType = wineStyleType
        self.criticsScores = criticsScores
        self.tastingNotes = tastingNotes
        self.foodPairings = foodPairings
        self.whenToDrinkYear = whenToDrinkYear
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
        self.winery = try container.decodeIfPresent(String.self, forKey: .winery)
        self.vintage = try container.decodeIfPresent(String.self, forKey: .vintage)
        self.region = try container.decodeIfPresent(String.self, forKey: .region)
        self.subRegion = try container.decodeIfPresent(String.self, forKey: .subRegion)
        self.country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        self.grapeVarieties = try container.decodeIfPresent(String.self, forKey: .grapeVarieties)
        self.alcoholContent = try container.decodeIfPresent(String.self, forKey: .alcoholContent) ?? ""
        
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
        
        // Try to decode food pairings - could be in multiple formats
        do {
            if container.contains(.foodPairings) {
                if let foodPairingsDict = try? container.decode([String: [String: String]].self, forKey: .foodPairings) {
                    var dishes: [FoodPairings.Dish] = []
                    for (_, dishInfo) in foodPairingsDict {
                        if let name = dishInfo["name"],
                           let ingredientType = dishInfo["ingredient_type"],
                           let explanation = dishInfo["explanation"] {
                            dishes.append(FoodPairings.Dish(
                                name: name,
                                ingredientType: ingredientType,
                                explanation: explanation
                            ))
                        }
                    }
                    self.foodPairings = FoodPairings(dishes: dishes)
                } else {
                    // If standard format fails, try alternative string format for backward compatibility
                    if let foodPairingsString = try container.decodeIfPresent(String.self, forKey: .foodPairings) {
                        let dish = FoodPairings.Dish(
                            name: "General Pairings",
                            ingredientType: "Mixed",
                            explanation: foodPairingsString
                        )
                        self.foodPairings = FoodPairings(dishes: [dish])
                    } else {
                        self.foodPairings = FoodPairings(dishes: [])
                    }
                }
            } else {
                self.foodPairings = FoodPairings(dishes: [])
            }
        } catch {
            print("Error decoding food pairings: \(error)")
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
        try container.encodeIfPresent(winery, forKey: .winery)
        try container.encodeIfPresent(vintage, forKey: .vintage)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(subRegion, forKey: .subRegion)
        try container.encode(country, forKey: .country)
        try container.encodeIfPresent(grapeVarieties, forKey: .grapeVarieties)
        try container.encode(alcoholContent, forKey: .alcoholContent)
        try container.encode(wineStyleType, forKey: .wineStyleType)
        try container.encode(criticsScores, forKey: .criticsScores)
        try container.encodeIfPresent(tastingNotes, forKey: .tastingNotes)
        try container.encodeIfPresent(foodPairings, forKey: .foodPairings)
        try container.encode(whenToDrinkYear, forKey: .whenToDrinkYear)
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