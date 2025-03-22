import Foundation
import SwiftUI

struct WineBottle: Identifiable, Codable {
    var id = UUID()
    var name: String
    var info: WineInfo
    var notes: String = ""
    var rating: Int = 0
    var dateAdded: Date = Date()
    var status: BottleStatus = .inCellar
    var quantity: Int = 1
    
    init(name: String, info: WineInfo, notes: String = "", rating: Int = 0) {
        self.name = name
        self.info = info
        self.notes = notes
        self.rating = rating
    }
}

enum BottleStatus: String, Codable {
    case inCellar
    case consumed
} 