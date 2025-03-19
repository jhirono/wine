import SwiftUI
import PhotosUI

struct MainContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var wineInfo: WineInfo?
    @State private var isAnalyzing = false
    @State private var showFullScreenImage = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image picker and preview
                    imageSection
                    
                    // Analysis button
                    analysisButton
                    
                    // Wine info display
                    if let wineInfo = wineInfo {
                        WineInfoView(wineInfo: wineInfo)
                    }
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Wine Analyzer")
            .fullScreenCover(isPresented: $showFullScreenImage) {
                if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    ZoomableImageView(image: uiImage, isShowing: $showFullScreenImage)
                }
            }
        }
    }
    
    private var imageSection: some View {
        VStack(spacing: 15) {
            if let selectedImageData = selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .onTapGesture {
                        showFullScreenImage = true
                    }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Text("Select a wine bottle image")
                            .foregroundColor(.gray)
                    )
            }
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Select Wine Photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        wineInfo = nil
                        errorMessage = nil
                    }
                }
            }
        }
    }
    
    private var analysisButton: some View {
        Button(action: {
            analyzeWine()
        }) {
            HStack {
                if isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 5)
                }
                Text(isAnalyzing ? "Analyzing..." : "Analyze Wine")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedImageData == nil || isAnalyzing ? Color.gray : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(selectedImageData == nil || isAnalyzing)
    }
    
    private func analyzeWine() {
        guard let imageData = selectedImageData else { return }
        
        isAnalyzing = true
        errorMessage = nil
        
        Task {
            do {
                let openAIService = OpenAIService()
                let result = try await openAIService.analyzeWineImage(imageData: imageData)
                
                DispatchQueue.main.async {
                    self.wineInfo = result
                    self.isAnalyzing = false
                }
            } catch let apiError as APIError {
                DispatchQueue.main.async {
                    switch apiError {
                    case .requestFailed(let message):
                        self.errorMessage = "Request failed: \(message)"
                    case .invalidResponse:
                        self.errorMessage = "Error: Invalid response from OpenAI API. Please try again with a clearer image."
                    case .decodingError:
                        self.errorMessage = "Error: Couldn't interpret the AI's response. Please try again."
                    }
                    self.isAnalyzing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.isAnalyzing = false
                }
            }
        }
    }
}

struct ZoomableImageView: View {
    let image: UIImage
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale *= delta
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            if scale > 1 {
                                scale = 1
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2
                            }
                        }
                )
                .onTapGesture {
                    isShowing = false
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isShowing = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    MainContentView()
} 