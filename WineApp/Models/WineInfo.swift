import Foundation

struct WineInfo: Identifiable, Codable {
    var id = UUID()
    var name: String
    var winery: String?
    var vintage: String?
    var region: String?
    var country: String = ""
    var grapeVarieties: String?
    var alcoholContent: String = ""
    var style: String = ""
    var tastingNotes: String?
    var foodPairings: String?
    var criticsScore: String = ""
    var agingPotential: String = ""
    var additionalInfo: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        winery: String? = nil,
        vintage: String? = nil,
        region: String? = nil,
        country: String = "",
        grapeVarieties: String? = nil,
        alcoholContent: String = "",
        style: String = "",
        tastingNotes: String? = nil,
        foodPairings: String? = nil,
        criticsScore: String = "",
        agingPotential: String = "",
        additionalInfo: String? = nil
    ) {
        self.id = id
        self.name = name
        self.winery = winery
        self.vintage = vintage
        self.region = region
        self.country = country
        self.grapeVarieties = grapeVarieties
        self.alcoholContent = alcoholContent
        self.style = style
        self.tastingNotes = tastingNotes
        self.foodPairings = foodPairings
        self.criticsScore = criticsScore
        self.agingPotential = agingPotential
        self.additionalInfo = additionalInfo
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case winery
        case vintage
        case region
        case country
        case grapeVarieties
        case alcoholContent
        case style
        case tastingNotes
        case foodPairings
        case criticsScore
        case agingPotential
        case additionalInfo
        
        // Alternative keys that might be in the response
        case grapeVariety
        case grape
        case grapes
        case varieties
        case foodPairing
        case pairing
        case pairings
        case tasting
        case tastingNote
        case notes
        case additional
        case info
        case description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        
        // Required fields with fallbacks
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        
        // Optional fields with alternative keys
        self.winery = try container.decodeIfPresent(String.self, forKey: .winery)
        self.vintage = try container.decodeIfPresent(String.self, forKey: .vintage)
        self.region = try container.decodeIfPresent(String.self, forKey: .region)
        self.country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        
        // Try multiple possible keys for grape varieties
        if let grapeVarieties = try container.decodeIfPresent(String.self, forKey: .grapeVarieties) {
            self.grapeVarieties = grapeVarieties
        } else if let grapeVariety = try container.decodeIfPresent(String.self, forKey: .grapeVariety) {
            self.grapeVarieties = grapeVariety
        } else if let grape = try container.decodeIfPresent(String.self, forKey: .grape) {
            self.grapeVarieties = grape
        } else if let grapes = try container.decodeIfPresent(String.self, forKey: .grapes) {
            self.grapeVarieties = grapes
        } else if let varieties = try container.decodeIfPresent(String.self, forKey: .varieties) {
            self.grapeVarieties = varieties
        }
        
        self.alcoholContent = try container.decodeIfPresent(String.self, forKey: .alcoholContent) ?? ""
        self.style = try container.decodeIfPresent(String.self, forKey: .style) ?? ""
        
        // Try multiple possible keys for tasting notes
        if let tastingNotes = try container.decodeIfPresent(String.self, forKey: .tastingNotes) {
            self.tastingNotes = tastingNotes
        } else if let tasting = try container.decodeIfPresent(String.self, forKey: .tasting) {
            self.tastingNotes = tasting
        } else if let tastingNote = try container.decodeIfPresent(String.self, forKey: .tastingNote) {
            self.tastingNotes = tastingNote
        } else if let notes = try container.decodeIfPresent(String.self, forKey: .notes) {
            self.tastingNotes = notes
        }
        
        // Try multiple possible keys for food pairings
        if let foodPairings = try container.decodeIfPresent(String.self, forKey: .foodPairings) {
            self.foodPairings = foodPairings
        } else if let foodPairing = try container.decodeIfPresent(String.self, forKey: .foodPairing) {
            self.foodPairings = foodPairing
        } else if let pairing = try container.decodeIfPresent(String.self, forKey: .pairing) {
            self.foodPairings = pairing
        } else if let pairings = try container.decodeIfPresent(String.self, forKey: .pairings) {
            self.foodPairings = pairings
        }
        
        self.criticsScore = try container.decodeIfPresent(String.self, forKey: .criticsScore) ?? ""
        self.agingPotential = try container.decodeIfPresent(String.self, forKey: .agingPotential) ?? ""
        
        // Try multiple possible keys for additional info
        if let additionalInfo = try container.decodeIfPresent(String.self, forKey: .additionalInfo) {
            self.additionalInfo = additionalInfo
        } else if let additional = try container.decodeIfPresent(String.self, forKey: .additional) {
            self.additionalInfo = additional
        } else if let info = try container.decodeIfPresent(String.self, forKey: .info) {
            self.additionalInfo = info
        } else if let description = try container.decodeIfPresent(String.self, forKey: .description) {
            self.additionalInfo = description
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode only the primary properties using their primary keys
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(winery, forKey: .winery)
        try container.encodeIfPresent(vintage, forKey: .vintage)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encode(country, forKey: .country)
        try container.encodeIfPresent(grapeVarieties, forKey: .grapeVarieties)
        try container.encode(alcoholContent, forKey: .alcoholContent)
        try container.encode(style, forKey: .style)
        try container.encodeIfPresent(tastingNotes, forKey: .tastingNotes)
        try container.encodeIfPresent(foodPairings, forKey: .foodPairings)
        try container.encode(criticsScore, forKey: .criticsScore)
        try container.encode(agingPotential, forKey: .agingPotential)
        try container.encodeIfPresent(additionalInfo, forKey: .additionalInfo)
        // Note: id is not encoded as it's not part of the API response structure
    }
} 