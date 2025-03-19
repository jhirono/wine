# Wine App Project Guidelines

## Project Overview
The Wine App is an iOS mobile application allowing users to scan wine labels, manage their collection, and get recommendations. Using GPT-4o for image analysis, the app extracts wine information from photos, stores it in a database, and provides insights such as food pairings, storage recommendations, and in-store comparison features.

## Personality Setting
**Teach me like a senior developer.**
Explanations should be clear but assume knowledge of software development fundamentals. Provide context for iOS-specific concepts, since the developer is new to iOS development but familiar with general programming and GPT-4o integration.

## Tech Stack
- **Frontend**: Swift/SwiftUI (iOS 16+)
- **Backend**: Firebase/CloudKit
- **Database**: Firestore/CloudKit
- **APIs**: 
  - OpenAI GPT-4o for image analysis and recommendations
  - Wine-Searcher API (potential integration) for price comparisons
- **Authentication**: Firebase Auth/Apple Sign-In
- **Storage**: Firebase Storage/CloudKit for wine images
- **Networking**: Swift URL Session, Combine framework
- **Testing**: XCTest, Swift UI Testing
- **Deployment**: TestFlight, App Store

## Environment Variables
**Note: These should be added to your local environment but never committed to source control**

```
OPENAI_API_KEY=your_openai_api_key
FIREBASE_API_KEY=your_firebase_api_key
WINE_SEARCHER_API_KEY=your_wine_searcher_api_key
ENVIRONMENT=development|production
LOG_LEVEL=debug|info|warning|error
```

## Standard Processes

### Creating a New Feature
1. Create feature branch from main: `git checkout -b feature/feature-name`
2. Create necessary models, views, and view models
3. Implement unit tests
4. Test on simulator and physical device
5. Submit PR for review
6. Merge after approval

### Error Fixing
1. Identify error source through logs and debugging
2. Create bug fix branch: `git checkout -b fix/bug-name`
3. Write test that reproduces the issue
4. Fix the issue and verify test passes
5. Submit PR with detailed description of the fix
6. Merge after approval

### Implementing GPT-4o Integration
1. Create a service class for API communication
2. Implement image preprocessing (compression, enhancement)
3. Set up proper error handling and retry logic
4. Cache responses to avoid redundant API calls
5. Create fallback mechanisms for offline operation

### GitHub Push Process
1. Add changes: `git add .`
2. Commit with descriptive message: `git commit -m "feat/fix/chore: description"`
3. Pull latest changes: `git pull origin main`
4. Resolve any conflicts
5. Push changes: `git push origin branch-name`
6. Create PR on GitHub

## File Structure

## Important Instructions

**ALWAYS follow these critical guidelines:**

1. **NEVER store API keys in source code.** Use environment variables or a secure configuration system.

2. **ALWAYS implement proper error handling for API calls.** The app should gracefully handle network failures and API limits.

3. **ALWAYS use MVVM architecture** to maintain separation of concerns and testability.

4. **NEVER force unwrap optionals (`!`)** unless absolutely necessary and documented why.

5. **ALWAYS implement caching for GPT-4o responses** to reduce API costs and improve performance.

6. **ALWAYS write unit tests** for business logic and services.

7. **NEVER block the main thread** with long-running operations.

## Commenting Best Practices

### Required Comment Types
1. **File Headers** - Purpose of the file, author, date
2. **Function Documentation** - Purpose, parameters, return values, throws
3. **Complex Logic** - Explanation of non-obvious implementations
4. **TODO/FIXME** - Clearly marked areas needing attention

### Comment Style for Swift
```swift
/// This is a documentation comment for a property or function
/// - Parameter name: Description of parameter
/// - Returns: Description of return value
/// - Throws: Description of potential errors

// This is a regular comment explaining implementation details

// MARK: - Section Divider

// TODO: Something that needs to be implemented later

// FIXME: Something that needs fixing
```

### Examples of Good Comments

```swift
/// Analyzes a wine label image using GPT-4o
/// - Parameter image: The UIImage of the wine label
/// - Returns: Structured wine information or nil if analysis failed
/// - Throws: NetworkError, APILimitError, or ParseError
func analyzeWineLabel(_ image: UIImage) async throws -> WineInfo? {
    // Compress image before sending to reduce API costs and improve speed
    let compressedImage = image.compressForAPIUpload()
    
    // TODO: Implement image preprocessing for better recognition accuracy
    
    // Attempt API call with retry logic for transient failures
    return try await apiService.performWithRetry {
        try await gpt4oService.analyzeImage(compressedImage)
    }
}
```

## Performance Considerations

1. **API Calls** - Batch when possible, implement caching, use background tasks
2. **Image Handling** - Compress before uploading, process in background
3. **Database** - Use pagination, avoid over-fetching, index properly
4. **UI** - Use lazy loading for lists, optimize view hierarchies 