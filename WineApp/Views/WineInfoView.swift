import SwiftUI

struct WineInfoView: View {
    let wineInfo: WineInfo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Wine Name and Winery
                VStack(alignment: .leading, spacing: 4) {
                    Text(wineInfo.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let winery = wineInfo.winery {
                        Text(winery)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        if let vintage = wineInfo.vintage {
                            Text(vintage)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !wineInfo.alcoholContent.isEmpty {
                            Text(wineInfo.alcoholContent)
                                .font(.subheadline)
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Divider()
                
                // Origin and Type
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Origin")
                            .font(.headline)
                        
                        Text(wineInfo.country)
                            .font(.body)
                        
                        if let region = wineInfo.region {
                            Text(region)
                                .font(.body)
                        }
                        
                        if let subRegion = wineInfo.subRegion {
                            Text(subRegion)
                                .font(.body)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Type")
                            .font(.headline)
                        
                        Text(wineInfo.wineStyleType)
                            .font(.body)
                        
                        if let grapeVarieties = wineInfo.grapeVarieties {
                            Text(grapeVarieties)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                
                // Tasting Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tasting Notes")
                        .font(.headline)
                    
                    if let tastingNotes = wineInfo.tastingNotes {
                        // Display structured tasting notes
                        TastingNotesView(tastingNotes: tastingNotes)
                    }
                }
                
                Divider()
                
                // Additional Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Information")
                        .font(.headline)
                    
                    if !wineInfo.criticsScores.isEmpty {
                        InfoRow(title: "Critics Scores", value: wineInfo.criticsScores)
                    }
                    
                    if !wineInfo.whenToDrinkYear.isEmpty {
                        InfoRow(title: "When to Drink", value: wineInfo.whenToDrinkYear)
                    }
                    
                    if let winery = wineInfo.winery, !winery.isEmpty {
                        InfoRow(title: "Producer", value: winery)
                    }
                    
                    if let subRegion = wineInfo.subRegion, !subRegion.isEmpty {
                        InfoRow(title: "Sub-Region", value: subRegion)
                    }
                    
                    // Always show some content in this section
                    if wineInfo.criticsScores.isEmpty && 
                       wineInfo.whenToDrinkYear.isEmpty && 
                       (wineInfo.winery == nil || wineInfo.winery?.isEmpty == true) &&
                       (wineInfo.subRegion == nil || wineInfo.subRegion?.isEmpty == true) {
                        Text("No additional information available")
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Food Pairings
                VStack(alignment: .leading, spacing: 10) {
                    Text("Food Pairings")
                        .font(.headline)
                    
                    if let foodPairings = wineInfo.foodPairings, !foodPairings.dishes.isEmpty {
                        // Display structured food pairings
                        FoodPairingsView(foodPairings: foodPairings)
                    } else {
                        Text("No food pairing information available")
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Wine Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

struct TastingNotesView: View {
    let tastingNotes: WineInfo.TastingNotes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !tastingNotes.aroma.isEmpty {
                InfoRow(title: "Aroma", value: tastingNotes.aroma)
            }
            
            if !tastingNotes.palate.isEmpty {
                InfoRow(title: "Palate", value: tastingNotes.palate)
            }
            
            if !tastingNotes.body.isEmpty {
                InfoRow(title: "Body", value: tastingNotes.body)
            }
            
            if !tastingNotes.finish.isEmpty {
                InfoRow(title: "Finish", value: tastingNotes.finish)
            }
        }
    }
}

struct FoodPairingsView: View {
    let foodPairings: WineInfo.FoodPairings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(foodPairings.dishes) { dish in
                DishView(dish: dish)
            }
        }
    }
}

struct DishView: View {
    let dish: WineInfo.FoodPairings.Dish
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text(dish.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(dish.ingredientType)
                        .font(.subheadline)
                        .padding(6)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(dish.explanation)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct WineInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let tastingNotes = WineInfo.TastingNotes(
            aroma: "Red berries, cherry, and subtle oak",
            palate: "Medium acidity with ripe tannins",
            body: "Medium to full",
            finish: "Long with notes of vanilla and spice"
        )
        
        let dish1 = WineInfo.FoodPairings.Dish(
            name: "Herb-Crusted Rack of Lamb",
            ingredientType: "Meat",
            explanation: "The rich lamb flavor pairs perfectly with the wine's tannins."
        )
        
        let dish2 = WineInfo.FoodPairings.Dish(
            name: "Aged Gouda",
            ingredientType: "Cheese",
            explanation: "The nutty flavors of the cheese complement the wine's fruit notes."
        )
        
        let foodPairings = WineInfo.FoodPairings(dishes: [dish1, dish2])
        
        let wineInfo = WineInfo(
            name: "Château Example Cabernet Sauvignon",
            winery: "Château Example",
            vintage: "2015",
            region: "Bordeaux",
            subRegion: "Saint-Émilion",
            country: "France",
            grapeVarieties: "Cabernet Sauvignon, Merlot",
            alcoholContent: "14.5%",
            wineStyleType: "Red Wine, Full-Bodied",
            criticsScores: "92 Points (Wine Spectator)",
            tastingNotes: tastingNotes,
            foodPairings: foodPairings,
            whenToDrinkYear: "2023-2030"
        )
        
        return NavigationView {
            WineInfoView(wineInfo: wineInfo)
        }
    }
} 