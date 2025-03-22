import SwiftUI
import PhotosUI

struct MainContentView: View {
    @EnvironmentObject var cellarManager: WineCellarManager
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImagesData: [Data] = []
    @State private var wineInfo: WineInfo?
    @State private var isAnalyzing = false
    @State private var showFullScreenImage = false
    @State private var selectedImageIndex: Int = 0
    @State private var errorMessage: String?
    
    // Camera functionality
    @State private var showCameraPicker = false
    @State private var capturedImage: UIImage?
    
    // Maximum number of images allowed
    private let maxImagesAllowed = 2
    
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
                            .environmentObject(cellarManager)
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
                if !selectedImagesData.isEmpty, selectedImageIndex < selectedImagesData.count,
                   let uiImage = UIImage(data: selectedImagesData[selectedImageIndex]) {
                    ZoomableImageView(image: uiImage, isShowing: $showFullScreenImage)
                }
            }
            .sheet(isPresented: $showCameraPicker) {
                ImagePicker(selectedImage: $capturedImage, isPresented: $showCameraPicker, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .onChange(of: capturedImage) { newImage in
                if let image = newImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                    // Add the captured image to the array
                    if selectedImagesData.count < maxImagesAllowed {
                        selectedImagesData.append(imageData)
                    } else {
                        // Replace the last image if we already have the max number
                        selectedImagesData = [imageData]
                    }
                    wineInfo = nil
                    errorMessage = nil
                    capturedImage = nil
                }
            }
        }
    }
    
    private var imageSection: some View {
        VStack(spacing: 15) {
            // Preview of selected images
            if !selectedImagesData.isEmpty {
                TabView {
                    ForEach(0..<selectedImagesData.count, id: \.self) { index in
                        if let uiImage = UIImage(data: selectedImagesData[index]) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .onTapGesture {
                                    selectedImageIndex = index
                                    showFullScreenImage = true
                                }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 350)
                
                // Remove image button
                if !selectedImagesData.isEmpty {
                    Button(action: {
                        selectedImagesData = []
                        selectedItems = []
                        wineInfo = nil
                        errorMessage = nil
                    }) {
                        Text("Clear Images")
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 8)
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Text("Select wine bottle images (up to \(maxImagesAllowed))")
                            .foregroundColor(.gray)
                    )
            }
            
            // Image selection buttons
            HStack(spacing: 10) {
                // Camera button
                Button(action: {
                    showCameraPicker = true
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Take Photo")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // Photo library button
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: maxImagesAllowed,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Photo Library")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .onChange(of: selectedItems) { newItems in
                    Task {
                        var newImagesData: [Data] = []
                        
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                newImagesData.append(data)
                            }
                        }
                        
                        // Update UI on the main thread
                        await MainActor.run {
                            selectedImagesData = newImagesData
                            wineInfo = nil
                            errorMessage = nil
                        }
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
            .background(selectedImagesData.isEmpty || isAnalyzing ? Color.gray : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(selectedImagesData.isEmpty || isAnalyzing)
    }
    
    private func analyzeWine() {
        guard !selectedImagesData.isEmpty else { return }
        
        isAnalyzing = true
        errorMessage = nil
        
        Task {
            do {
                let openAIService = OpenAIService()
                let result = try await openAIService.analyzeWineImages(imagesData: selectedImagesData)
                
                await MainActor.run {
                    self.wineInfo = result
                    self.isAnalyzing = false
                }
            } catch let apiError as APIError {
                await MainActor.run {
                    switch apiError {
                    case .requestFailed(let message):
                        self.errorMessage = "Request failed: \(message)"
                    case .invalidResponse:
                        self.errorMessage = "Error: Invalid response from OpenAI API. Please try again with a clearer image."
                    case .decodingError:
                        self.errorMessage = "Error: Couldn't interpret the AI's response. Please try again."
                    case .tooManyImages:
                        self.errorMessage = "Error: Too many images selected. Please select up to \(maxImagesAllowed) images."
                    }
                    self.isAnalyzing = false
                }
            } catch {
                await MainActor.run {
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