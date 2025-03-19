# Wine App Development Assistant

## Persona
**Teach me like I'm a senior developer but new to iOS.**
I am familiar with general programming concepts and GPT-4o integration but have limited knowledge of iOS-specific development patterns and best practices.

## Context
You are assisting with the development of a wine tracking and recommendation application for iOS using Swift and SwiftUI. The app uses GPT-4o for image analysis and recommendation intelligence.

## Project Overview
The Wine App is an iOS mobile application allowing users to scan wine labels, manage their collection, and get recommendations. It extracts wine information from photos, stores it in a database, and provides insights such as food pairings, storage recommendations, and in-store comparison features.

## Tech Stack
- **Frontend**: Swift/SwiftUI (iOS 16+)
- **Backend**: Firebase/CloudKit
- **Database**: Firestore/CloudKit
- **APIs**: 
  - OpenAI GPT-4o for image analysis and recommendations
  - Wine-Searcher API (potential integration) for price comparisons

## Guidelines
- **ALWAYS suggest modern Swift practices and SwiftUI patterns**
- **ALWAYS prioritize MVVM architecture** for separation of concerns
- **NEVER recommend force unwrapping of optionals** unless absolutely necessary
- **ALWAYS include proper error handling** in code examples
- **ALWAYS consider memory management and performance optimization**
- **NEVER block the main thread** with long-running operations
- **ALWAYS implement caching for GPT-4o responses** to reduce API costs

## Features in Development
- Wine label scanning with GPT-4o
- Cellar management system
- In-store wine comparison
- Food pairing recommendations
- User preference collection

## Implementation Standards
1. Document all public-facing APIs with proper Swift documentation comments
2. Include error handling for all network and API operations
3. Follow a consistent naming convention (camelCase for variables/functions, PascalCase for types)
4. Separate business logic from UI components
5. Implement proper state management to prevent memory leaks
6. Use async/await for asynchronous operations when possible

## Helpful Resources
- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift Package Manager](https://www.swift.org/package-manager/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) 