import Foundation
import SwiftUI
import Combine

class WineCellarManager: ObservableObject {
    @Published var bottles: [WineBottle] = []
    
    init() {
        load()
    }
    
    func addBottle(bottle: WineBottle) {
        bottles.append(bottle)
        save()
    }
    
    func removeBottle(at index: Int) {
        guard index >= 0 && index < bottles.count else { return }
        bottles.remove(at: index)
        save()
    }
    
    func updateBottle(id: UUID, updatedBottle: WineBottle) {
        if let index = bottles.firstIndex(where: { $0.id == id }) {
            bottles[index] = updatedBottle
            save()
        }
    }
    
    // MARK: - Persistence
    
    private func save() {
        do {
            let encoded = try JSONEncoder().encode(bottles)
            UserDefaults.standard.set(encoded, forKey: "wineCellar")
            print("Successfully saved \(bottles.count) bottles to UserDefaults")
        } catch {
            print("Failed to save bottles: \(error.localizedDescription)")
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: "wineCellar") {
            do {
                bottles = try JSONDecoder().decode([WineBottle].self, from: data)
                print("Successfully loaded \(bottles.count) bottles from UserDefaults")
            } catch {
                print("Failed to load bottles: \(error.localizedDescription)")
                bottles = []
            }
        }
    }
} 