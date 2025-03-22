import SwiftUI

struct CellarWineDetailView: View {
    @EnvironmentObject var cellarManager: WineCellarManager
    @State var bottle: WineBottle
    @State private var notes: String
    @State private var rating: Int
    @State private var quantity: Int
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    
    init(bottle: WineBottle) {
        self._bottle = State(initialValue: bottle)
        self._notes = State(initialValue: bottle.notes)
        self._rating = State(initialValue: bottle.rating)
        self._quantity = State(initialValue: bottle.quantity)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Wine Info Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(bottle.info.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(bottle.info.winery)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        if let vintage = bottle.info.vintage {
                            Text(vintage)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text(bottle.info.wineStyleType)
                            .font(.headline)
                            .padding(6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                Divider()
                
                // Wine Details Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Wine Details")
                        .font(.headline)
                    
                    InfoRow(title: "Country", value: bottle.info.country)
                    
                    if !bottle.info.region.isEmpty {
                        InfoRow(title: "Region", value: bottle.info.region)
                    }
                    
                    if let grapeVarieties = bottle.info.grapeVarieties {
                        InfoRow(title: "Grape Varieties", value: grapeVarieties)
                    }
                    
                    if !bottle.info.alcoholContent.isEmpty {
                        InfoRow(title: "Alcohol Content", value: bottle.info.alcoholContent)
                    }
                }
                
                Divider()
                
                // Quantity Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Quantity")
                            .font(.headline)
                        
                        Spacer()
                        
                        if isEditing {
                            Stepper("\(quantity) bottle(s)", value: $quantity, in: 1...100)
                                .fixedSize()
                        } else {
                            Text("\(bottle.quantity) bottle(s)")
                                .font(.body)
                        }
                    }
                }
                
                Divider()
                
                // Personal Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Personal Notes")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            isEditing.toggle()
                            if !isEditing {
                                // Save changes
                                var updatedBottle = bottle
                                updatedBottle.notes = notes
                                updatedBottle.rating = rating
                                updatedBottle.quantity = quantity
                                cellarManager.updateBottle(id: bottle.id, updatedBottle: updatedBottle)
                                bottle = updatedBottle
                            }
                        }) {
                            Text(isEditing ? "Done" : "Edit")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if isEditing {
                        // Rating Editor
                        HStack {
                            Text("Rating:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .foregroundColor(index <= rating ? .yellow : .gray)
                                    .onTapGesture {
                                        rating = index
                                    }
                            }
                        }
                        
                        // Notes Editor
                        TextEditor(text: $notes)
                            .frame(minHeight: 150)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        // Rating Display
                        HStack {
                            Text("Rating:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= bottle.rating ? "star.fill" : "star")
                                    .foregroundColor(index <= bottle.rating ? .yellow : .gray)
                            }
                        }
                        
                        // Notes Display
                        if bottle.notes.isEmpty {
                            Text("No notes added yet")
                                .italic()
                                .foregroundColor(.secondary)
                        } else {
                            Text(bottle.notes)
                                .font(.body)
                        }
                    }
                    
                    // Added Date
                    HStack {
                        Spacer()
                        Text("Added on \(bottle.dateAdded, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Status Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Status")
                        .font(.headline)
                    
                    if bottle.status == .inCellar {
                        Button(action: {
                            var updatedBottle = bottle
                            updatedBottle.status = .consumed
                            cellarManager.updateBottle(id: bottle.id, updatedBottle: updatedBottle)
                            bottle = updatedBottle
                        }) {
                            HStack {
                                Image(systemName: "wineglass")
                                Text("Mark as Consumed")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    } else {
                        Button(action: {
                            var updatedBottle = bottle
                            updatedBottle.status = .inCellar
                            cellarManager.updateBottle(id: bottle.id, updatedBottle: updatedBottle)
                            bottle = updatedBottle
                        }) {
                            HStack {
                                Image(systemName: "arrow.uturn.backward")
                                Text("Return to Cellar")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                
                Divider()
                
                // Delete Button
                Button(action: {
                    cellarManager.removeBottle(at: cellarManager.bottles.firstIndex(where: { $0.id == bottle.id }) ?? 0)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Remove from Cellar")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Wine Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
} 