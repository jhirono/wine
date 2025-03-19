import SwiftUI

struct WineInfoView: View {
    let wineInfo: WineInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Wine Name and Basic Info
            VStack(alignment: .leading, spacing: 8) {
                Text(wineInfo.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let winery = wineInfo.winery, !winery.isEmpty {
                    Text(winery)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                if let vintage = wineInfo.vintage, !vintage.isEmpty {
                    Text("Vintage: \(vintage)")
                        .font(.subheadline)
                }
                
                if let region = wineInfo.region, !region.isEmpty {
                    Text("Region: \(region)")
                        .font(.subheadline)
                }
            }
            .padding(.bottom, 5)
            
            Divider()
            
            // Grape Varieties
            if let grapeVarieties = wineInfo.grapeVarieties, !grapeVarieties.isEmpty {
                infoSection(title: "Grape Varieties", content: grapeVarieties)
            }
            
            // Tasting Notes
            if let tastingNotes = wineInfo.tastingNotes, !tastingNotes.isEmpty {
                infoSection(title: "Tasting Notes", content: tastingNotes)
            }
            
            // Food Pairings
            if let foodPairings = wineInfo.foodPairings, !foodPairings.isEmpty {
                infoSection(title: "Food Pairings", content: foodPairings)
            }
            
            // Additional Information
            if let additionalInfo = wineInfo.additionalInfo, !additionalInfo.isEmpty {
                infoSection(title: "Additional Information", content: additionalInfo)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 5)
    }
}

#Preview {
    WineInfoView(wineInfo: WineInfo(
        name: "Château Margaux 2015",
        winery: "Château Margaux",
        vintage: "2015",
        region: "Bordeaux, France",
        grapeVarieties: "Cabernet Sauvignon, Merlot, Petit Verdot, Cabernet Franc",
        tastingNotes: "Complex bouquet with notes of black fruits, violets, and cedar. Full-bodied with silky tannins and a long, elegant finish.",
        foodPairings: "Pairs well with roasted lamb, beef tenderloin, and aged cheeses.",
        additionalInfo: "This vintage received a perfect 100-point score from several wine critics and is considered one of the finest expressions of Château Margaux."
    ))
} 