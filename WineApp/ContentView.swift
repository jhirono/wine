import SwiftUI

struct ContentView: View {
    @StateObject private var cellarManager = WineCellarManager()
    
    var body: some View {
        TabView {
            MainContentView()
                .tabItem {
                    Label("Analyzer", systemImage: "camera.viewfinder")
                }
            
            CellarView()
                .tabItem {
                    Label("My Cellar", systemImage: "wineglass")
                }
        }
        .environmentObject(cellarManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 