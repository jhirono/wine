# Wine Analyzer App

A powerful iOS application that lets you analyze wine bottles using computer vision and AI. Take or select a photo of any wine bottle, and our app uses OpenAI's GPT-4o model to provide detailed, sommelier-level information about the wine.

## Features

- Clean, modern UI with intuitive controls
- Select wine bottle photos from your photo library
- Full-screen image viewing capability
- Analyze wines using OpenAI's GPT-4o model with advanced prompt engineering
- View comprehensive wine information including:
  - Wine name with special designations and cuvée names
  - Winery/producer with historical context
  - Vintage details with quality assessment for that year
  - Specific regions, sub-regions, and appellations
  - Country of origin
  - Grape varieties with approximate percentages
  - Alcohol content
  - Detailed wine style and body characteristics
  - Rich tasting notes with primary, secondary, and tertiary flavors
  - Creative and specific food pairing suggestions
  - Critics' scores with specific rating sources
  - Aging potential and drinking window recommendations

## Setup

1. Clone the repository
2. Open the WineApp.xcodeproj in Xcode
3. Add your OpenAI API key in `WineApp/Services/APIConfig.swift`
   ```swift
   static let openAIKey = "YOUR_OPENAI_API_KEY"
   ```
4. Build and run the app on your iOS device or simulator

## Requirements

- iOS 16.0+
- Xcode 14.0+
- OpenAI API key with access to GPT-4o

## How to Use

1. Open the app
2. Tap "Select Wine Photo" to choose a wine bottle image from your photo library
3. Tap "Analyze Wine" to send the image to OpenAI for analysis
4. View the detailed wine information displayed with an elegant, organized interface
5. Tap on the wine bottle image to view it in full-screen mode

## Enhanced Wine Analysis

Our app doesn't just identify basic information - it provides sommelier-level analysis by:

- Identifying the full wine name including special designations
- Providing context about the winery and its reputation
- Offering vintage quality assessment for the specific region
- Breaking down grape varietals with approximate percentages when possible
- Describing wine style in detail including body, sweetness, and structure
- Creating comprehensive tasting notes covering aroma, palate, and finish
- Suggesting specific food pairings including regional dishes
- Providing critics' scores with the exact rating source
- Estimating aging potential with specific drinking windows

## Project Structure

- **Models**: Contains the data structures for the app
  - `WineInfo.swift`: Model for storing enriched wine information
- **Views**: Contains the SwiftUI views
  - `MainContentView.swift`: Main screen with improved UI for photo selection and analysis
  - `WineInfoView.swift`: Elegant display of the analyzed wine information
- **Services**: Contains API and service logic
  - `APIConfig.swift`: Configuration for the OpenAI API
  - `OpenAIService.swift`: Enhanced prompts for richer wine analysis

## Future Enhancements

- Camera integration for capturing photos directly
- Saving wine data to a local database
- Collection management features
- Social sharing functionality
- Wine recommendation system based on preferences
- OCR-enhanced label reading for better accuracy
- Wine price estimation
- Cellar management tools
- Integration with wine marketplaces

## License

MIT License 