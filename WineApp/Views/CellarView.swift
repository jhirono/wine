import SwiftUI

struct CellarView: View {
    @EnvironmentObject var cellarManager: WineCellarManager
    @State private var selectedTab = 0 // 0 for inCellar, 1 for consumed
    
    var body: some View {
        NavigationView {
            VStack {
                // Status filter
                Picker("Wine Status", selection: $selectedTab) {
                    Text("In Cellar").tag(0)
                    Text("Consumed").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                List {
                    if filteredBottles.isEmpty {
                        Text(selectedTab == 0 ? "Your wine cellar is empty. Add some wines!" : "No consumed wines yet.")
                            .foregroundColor(.gray)
                            .italic()
                            .padding()
                    } else {
                        ForEach(filteredBottles) { bottle in
                            NavigationLink(destination: CellarWineDetailView(bottle: bottle)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(bottle.info.name)
                                            .font(.headline)
                                        Text(bottle.info.winery)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        HStack {
                                            Text(bottle.info.wineStyleType)
                                            if let vintage = bottle.info.vintage {
                                                Text("• \(vintage)")
                                            }
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        if bottle.rating > 0 {
                                            HStack {
                                                Text("\(bottle.rating)")
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                            .font(.caption)
                                        }
                                        
                                        Text("\(bottle.quantity) bottle\(bottle.quantity > 1 ? "s" : "")")
                                            .font(.caption)
                                            .padding(4)
                                            .background(Color.green.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteBottle)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("My Wine Cellar")
        }
    }
    
    private var filteredBottles: [WineBottle] {
        return cellarManager.bottles.filter { bottle in
            return selectedTab == 0 ? bottle.status == .inCellar : bottle.status == .consumed
        }
    }
    
    private func deleteBottle(at offsets: IndexSet) {
        // We need to map the indices from filtered array to the full array
        let bottlesToDelete = offsets.map { filteredBottles[$0] }
        
        for bottle in bottlesToDelete {
            if let index = cellarManager.bottles.firstIndex(where: { $0.id == bottle.id }) {
                cellarManager.removeBottle(at: index)
            }
        }
    }
}

struct CellarView_Previews: PreviewProvider {
    static var previews: some View {
        CellarView()
            .environmentObject(WineCellarManager())
    }
} 