# Wine Cellar Management Implementation Plan

## Overview
Add basic cellar management functionality to the WineApp, allowing users to:
- Save analyzed wines to their cellar from the Wine Analyzer tab
- View saved wines in a dedicated Cellar tab
- Manage their wine collection (view details, mark as consumed, adjust quantity)

## Implementation Steps

### 1. Data Model

```swift
// Add to a new file: WineApp/Models/WineBottle.swift
struct WineBottle: Codable, Identifiable {
    var id = UUID()
    var wineInfo: WineInfo  // Reuse existing WineInfo model
    var quantity: Int = 1
    var status: BottleStatus = .inCellar
    var dateAdded: Date = Date()
    var consumedDate: Date?
}

enum BottleStatus: String, Codable {
    case inCellar
    case consumed
}
```

### 2. Cellar Manager

```swift
// Add to a new file: WineApp/Services/WineCellarManager.swift
class WineCellarManager: ObservableObject {
    @Published private(set) var wineBottles: [WineBottle] = []
    private let fileURL: URL
    
    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("wineCellar.json")
        loadWineBottles()
    }
    
    func loadWineBottles() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            wineBottles = try JSONDecoder().decode([WineBottle].self, from: data)
        } catch {
            print("Error loading wine bottles: \(error)")
        }
    }
    
    func saveWineBottles() {
        do {
            let data = try JSONEncoder().encode(wineBottles)
            try data.write(to: fileURL)
        } catch {
            print("Error saving wine bottles: \(error)")
        }
    }
    
    func addWineBottle(_ wineInfo: WineInfo) {
        let newBottle = WineBottle(wineInfo: wineInfo)
        wineBottles.append(newBottle)
        saveWineBottles()
    }
    
    func updateBottleStatus(id: UUID, status: BottleStatus) {
        if let index = wineBottles.firstIndex(where: { $0.id == id }) {
            wineBottles[index].status = status
            if status == .consumed {
                wineBottles[index].consumedDate = Date()
            } else {
                wineBottles[index].consumedDate = nil
            }
            saveWineBottles()
        }
    }
    
    func updateBottleQuantity(id: UUID, quantity: Int) {
        if let index = wineBottles.firstIndex(where: { $0.id == id }) {
            wineBottles[index].quantity = max(1, quantity)
            saveWineBottles()
        }
    }
}
```

### 3. Adding "Add to Cellar" Feature in Wine Analyzer

Modify the `WineInfoView.swift` file to include an "Add to Cellar" button.

```swift
// Update WineApp/Views/WineInfoView.swift
struct WineInfoView: View {
    var wineInfo: WineInfo
    @EnvironmentObject var cellarManager: WineCellarManager
    @State private var showingAddedToCellarAlert = false
    
    // Keep existing view code...
    
    // Add this to the view body near the bottom
    Button(action: {
        cellarManager.addWineBottle(wineInfo)
        showingAddedToCellarAlert = true
    }) {
        HStack {
            Image(systemName: "plus.circle")
            Text("Add to Cellar")
        }
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .padding()
    .alert("Added to Cellar", isPresented: $showingAddedToCellarAlert) {
        Button("OK", role: .cancel) { }
    }
}
```

### 4. Creating Cellar Tab Views

#### Cellar List View

```swift
// Add to a new file: WineApp/Views/CellarView.swift
struct CellarView: View {
    @EnvironmentObject var cellarManager: WineCellarManager
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab selector
                Picker("Cellar Status", selection: $selectedTab) {
                    Text("In Cellar").tag(0)
                    Text("Consumed").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Wine bottles list
                List {
                    ForEach(filteredBottles) { bottle in
                        NavigationLink(destination: CellarWineDetailView(bottle: bottle)) {
                            CellarWineRow(bottle: bottle)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("My Wine Cellar")
        }
    }
    
    var filteredBottles: [WineBottle] {
        cellarManager.wineBottles.filter { bottle in
            if selectedTab == 0 {
                return bottle.status == .inCellar
            } else {
                return bottle.status == .consumed
            }
        }
    }
}

struct CellarWineRow: View {
    let bottle: WineBottle
    
    var body: some View {
        HStack {
            // Wine image
            if let imagePath = bottle.wineInfo.imagePath {
                if let image = loadImage(filename: imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "wineglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(5)
                }
            } else {
                Image(systemName: "wineglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(5)
            }
            
            // Wine details
            VStack(alignment: .leading) {
                Text(bottle.wineInfo.name)
                    .font(.headline)
                
                if let vintage = bottle.wineInfo.vintage {
                    Text("Vintage: \(vintage)")
                        .font(.subheadline)
                }
                
                Text(bottle.wineInfo.producer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quantity badge
            Text("\(bottle.quantity)")
                .font(.headline)
                .padding(8)
                .background(Circle().fill(Color.blue.opacity(0.2)))
        }
        .padding(.vertical, 4)
    }
    
    func loadImage(filename: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
}
```

#### Wine Detail View in Cellar

```swift
// Add to a new file: WineApp/Views/CellarWineDetailView.swift
struct CellarWineDetailView: View {
    @EnvironmentObject var cellarManager: WineCellarManager
    let bottle: WineBottle
    @State private var quantity: Int
    
    init(bottle: WineBottle) {
        self.bottle = bottle
        _quantity = State(initialValue: bottle.quantity)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Wine image
                if let imagePath = bottle.wineInfo.imagePath, 
                   let image = loadImage(filename: imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // Wine details
                Group {
                    Text(bottle.wineInfo.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let vintage = bottle.wineInfo.vintage {
                        detailRow(title: "Vintage", value: "\(vintage)")
                    }
                    
                    detailRow(title: "Producer", value: bottle.wineInfo.producer)
                    
                    if let region = bottle.wineInfo.region {
                        detailRow(title: "Region", value: region)
                    }
                    
                    if let country = bottle.wineInfo.country {
                        detailRow(title: "Country", value: country)
                    }
                    
                    if let varietal = bottle.wineInfo.varietal {
                        detailRow(title: "Varietal", value: varietal)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Bottle management
                VStack(alignment: .leading) {
                    Text("Bottle Management")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    // Quantity stepper
                    HStack {
                        Text("Quantity:")
                        Spacer()
                        Button(action: { 
                            quantity = max(1, quantity - 1)
                            cellarManager.updateBottleQuantity(id: bottle.id, quantity: quantity)
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.title2)
                        }
                        
                        Text("\(quantity)")
                            .font(.title2)
                            .frame(width: 40, alignment: .center)
                        
                        Button(action: { 
                            quantity += 1
                            cellarManager.updateBottleQuantity(id: bottle.id, quantity: quantity)
                        }) {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Status toggle button
                    if bottle.status == .inCellar {
                        Button(action: {
                            cellarManager.updateBottleStatus(id: bottle.id, status: .consumed)
                        }) {
                            Label("Mark as Consumed", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(action: {
                            cellarManager.updateBottleStatus(id: bottle.id, status: .inCellar)
                        }) {
                            Label("Return to Cellar", systemImage: "arrow.uturn.backward")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Wine Details")
    }
    
    func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title + ":")
                .fontWeight(.semibold)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
    
    func loadImage(filename: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
}
```

### 5. Update App Structure for Tab Navigation

Modify `WineAppApp.swift` to include the tab navigation.

```swift
// Update WineApp/WineAppApp.swift
@main
struct WineAppApp: App {
    @StateObject private var cellarManager = WineCellarManager()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Wine Analyzer", systemImage: "camera")
                    }
                    .environmentObject(cellarManager)
                
                CellarView()
                    .tabItem {
                        Label("My Cellar", systemImage: "wineglass")
                    }
                    .environmentObject(cellarManager)
            }
        }
    }
}
```

## Testing Plan

1. Add several wines to the cellar using the Wine Analyzer
2. Verify wines appear in the "In Cellar" tab
3. Test marking wines as consumed and verify they move to the "Consumed" tab
4. Test returning wines to cellar from consumed state
5. Test quantity adjustments
6. Verify images load correctly

## Future Enhancements (Not in Initial Implementation)

- Search and filtering
- Sorting options
- Categories/tags for wines
- More detailed wine notes
- Wine ratings
- Export/backup functionality
