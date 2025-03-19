# WineApp - Implementation Details

## Overview

WineApp is an iOS application that uses machine learning to analyze wine bottles from images. The app leverages OpenAI's GPT-4o vision model to extract and present detailed information about a wine based on a photo of the bottle.

## Architecture

The app follows a clean architecture pattern with separation of concerns:

- **Models**: Data structures for the application
- **Views**: SwiftUI views for the user interface
- **Services**: API integration and business logic

## Core Components

### Models

#### WineInfo.swift
- Central data model for storing wine information
- Implements `Identifiable` and `Codable` protocols
- Properties include:
  - Basic wine details (name, winery, vintage, region, country)
  - Grape varieties
  - Characteristics (alcohol content, style)
  - Tasting notes and food pairings
  - Critics score and aging potential
  - Additional information
- Robust JSON decoding with support for alternative key names
- Custom initializer and encoder/decoder implementations for flexibility

### Views

#### MainContentView.swift
- Main screen of the application with:
  - Photo selection interface using `PhotosPicker`
  - Image preview with zoom capability
  - Analysis button to initiate wine identification
  - Progress indicator during analysis
  - Error handling and display
  - Integration with `WineInfoView` to display results
- Implements `ZoomableImageView` for full-screen viewing with gestures for:
  - Pinch to zoom
  - Drag to pan
  - Double-tap to reset or zoom
  - Single-tap to dismiss

#### WineInfoView.swift
- Elegant display of wine information with:
  - Wine name and basic details in prominent position
  - Sections for grape varieties, tasting notes, and food pairings
  - Formatted display of additional information
  - Responsive layout with proper spacing and typography
  - Custom styling with shadows and rounded corners

### Services

#### APIConfig.swift
- Configuration for OpenAI API:
  - API endpoint URLs
  - Model selection (GPT-4o)
  - Secure storage of API key in iOS Keychain
  - Fallback mechanism for development
  - Keychain operations for storing and retrieving the API key

#### OpenAIService.swift
- Handles communication with OpenAI's API:
  - Image analysis using GPT-4o's vision capabilities
  - Conversion of images to base64 format
  - Construction of prompt for wine analysis
  - API request formation and execution
  - Response parsing and error handling
  - Robust JSON extraction and model creation

## Key Features

1. **Image Selection**: Users can select wine bottle images from their photo library.
2. **Image Viewing**: Selected images can be viewed in full screen with zoom capabilities.
3. **AI Analysis**: Wine bottle images are analyzed using OpenAI's GPT-4o model.
4. **Detailed Wine Information**: The app displays comprehensive information about the analyzed wine.
5. **Error Handling**: Robust error handling with user-friendly error messages.
6. **Secure API Key Storage**: The OpenAI API key is securely stored in the iOS Keychain.

## Technical Implementation

- **SwiftUI**: Modern declarative UI framework for building the interface
- **PhotosUI**: Integration for accessing the device's photo library
- **Async/Await**: Modern Swift concurrency for network operations
- **Swift Keychain**: Secure storage for API credentials
- **OpenAI GPT-4o**: State-of-the-art vision-language model for image analysis

## Error Handling

The app implements custom error types through `APIError`:
- `requestFailed`: When API requests fail with specific error messages
- `invalidResponse`: When the response cannot be parsed correctly
- `decodingError`: When the JSON response cannot be decoded to the WineInfo model

## Security Considerations

- API keys are stored securely in the iOS Keychain rather than hardcoded in the source code
- Only necessary permissions are requested from the user (photo library access)
- Network requests use HTTPS for secure communication

## Future Enhancements

- Camera integration for capturing photos directly
- Wine collection management
- Offline mode with cached results
- Social sharing functionality
- Wine recommendation system
- OCR-enhanced label reading
- Wine price estimation
- Cellar management tools
- Integration with wine marketplaces
