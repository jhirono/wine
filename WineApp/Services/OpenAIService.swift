import Foundation
import UIKit

enum APIError: Error {
    case requestFailed(String)
    case invalidResponse
    case decodingError
    case tooManyImages
}

class OpenAIService {
    
    // Maximum number of images allowed for analysis
    private let maxImagesAllowed = 2
    
    // Single image analysis method (for backward compatibility)
    func analyzeWineImage(imageData: Data) async throws -> WineInfo {
        return try await analyzeWineImages(imagesData: [imageData])
    }
    
    // New method to handle multiple images
    func analyzeWineImages(imagesData: [Data]) async throws -> WineInfo {
        // Validate number of images
        if imagesData.isEmpty {
            throw APIError.requestFailed("No images provided")
        }
        
        if imagesData.count > maxImagesAllowed {
            throw APIError.tooManyImages
        }
        
        // Convert all images to base64
        let base64Images = imagesData.compactMap { convertImageToBase64(imageData: $0) }
        if base64Images.count != imagesData.count {
            print("DEBUG: Failed to convert one or more images to base64")
            throw APIError.requestFailed("Failed to convert one or more images to base64")
        }
        
        // Step 1: Get basic wine information with lower temperature
        print("DEBUG: Starting Step 1 - Basic Wine Analysis with \(base64Images.count) images")
        let step1Result = try await performWineAnalysis(
            base64Images: base64Images,
            prompt: createStep1Prompt(),
            temperature: 0.2,
            topP: 0.3,
            maxTokens: 700
        )
        
        print("DEBUG: Step 1 completed, parsing result")
        var wineInfo = try parseStep1Response(data: step1Result)
        
        // Step 2: Get food pairings with higher temperature for creativity
        print("DEBUG: Starting Step 2 - Food Pairing Analysis")
        let step2Prompt = createStep2Prompt(wineInfo: wineInfo)
        let step2Result = try await performWineAnalysis(
            base64Images: nil, // No need for image in step 2
            prompt: step2Prompt,
            temperature: 0.8,
            topP: 0.9,
            maxTokens: 1000
        )
        
        print("DEBUG: Step 2 completed, parsing result")
        let foodPairings = try parseStep2Response(data: step2Result)
        
        // Update the wine info with the food pairings
        wineInfo.foodPairings = foodPairings
        
        return wineInfo
    }
    
    private func performWineAnalysis(
        base64Images: [String]?,
        prompt: String,
        temperature: Double,
        topP: Double,
        maxTokens: Int
    ) async throws -> Data {
        var messages: [[String: Any]] = [
            [
                "role": "system",
                "content": prompt
            ]
        ]
        
        if let base64Images = base64Images, !base64Images.isEmpty {
            var content: [[String: Any]] = [
                [
                    "type": "text",
                    "text": "Analyze this wine bottle image" + (base64Images.count > 1 ? "s" : "") + " and provide detailed information about the wine."
                ]
            ]
            
            // Add each image to the content array
            for base64Image in base64Images {
                content.append([
                    "type": "image_url",
                    "image_url": [
                        "url": "data:image/jpeg;base64,\(base64Image)"
                    ]
                ])
            }
            
            messages.append([
                "role": "user",
                "content": content
            ])
        } else {
            messages.append([
                "role": "user",
                "content": "Based on the wine details provided, generate food pairings."
            ])
        }
        
        let requestBody: [String: Any] = [
            "model": APIConfig.openAIModel,
            "messages": messages,
            "max_tokens": maxTokens,
            "temperature": temperature,
            "top_p": topP,
            "response_format": ["type": "json_object"]
        ]
        
        guard let url = URL(string: APIConfig.openAIEndpoint) else {
            print("DEBUG: Invalid API endpoint")
            throw APIError.requestFailed("Invalid API endpoint")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIConfig.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("DEBUG: Failed to serialize request body")
            throw APIError.requestFailed("Failed to serialize request body")
        }
        
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("DEBUG: Not an HTTP response")
                throw APIError.invalidResponse
            }
            
            print("DEBUG: Response status code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("DEBUG: API error response: \(responseString)")
                throw APIError.requestFailed("API request failed with status \(httpResponse.statusCode): \(responseString)")
            }
            
            // Print the response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("DEBUG: API successful response: \(responseString)")
            }
            
            return data
        } catch {
            print("DEBUG: Network request error: \(error)")
            throw error
        }
    }
    
    private func convertImageToBase64(imageData: Data) -> String? {
        return imageData.base64EncodedString()
    }
    
    private func createStep1Prompt() -> String {
        return """
        Analyze this wine bottle image and provide detailed information about the wine. Use both the visible label details and reputable wine source data to enhance your response. Return the information in JSON format with the following keys:

        {
          "winery_producer": "",
          "wine_name": "",
          "vintage": "",
          "country": "",
          "region": "",
          "sub-region": "",
          "grape_varieties": "",  // Only list grape variety names without additional descriptions.
          "alcohol_content": "",  // In percentage format (e.g., "13.5%").
          "wine_style_type": "",
          "critics_scores": "",  // Provide numerical ratings or indicate "N/A" if unavailable.
          "tasting_notes": {
            "aroma": "",
            "palate": "",
            "body": "",
            "finish": ""
          },
          "when_to_drink_year": "",  // Return only numeric years (e.g., "2024-2030"), no additional text.
          "decanting_time": "" // Return recommended decanting time in minutes
        }
        """
    }
    
    private func createStep2Prompt(wineInfo: WineInfo) -> String {
        let aroma = wineInfo.tastingNotes?.aroma ?? ""
        let palate = wineInfo.tastingNotes?.palate ?? ""
        let body = wineInfo.tastingNotes?.body ?? ""
        let finish = wineInfo.tastingNotes?.finish ?? ""
        
        return """
        Based on the following wine details, generate **creative and well-balanced food pairings** that complement its flavor profile. Provide at least 6 pairings covering meats, seafood, vegetables, cheeses, appetizers, and desserts.

        {
          "wine_name": "\(wineInfo.name)",
          "country": "\(wineInfo.country)",
          "region": "\(wineInfo.region)",
          "sub-region": "\(wineInfo.subRegion ?? "")",
          "grape_varieties": "\(wineInfo.grapeVarieties ?? "")",
          "tasting_notes": {
            "aroma": "\(aroma)",
            "palate": "\(palate)",
            "body": "\(body)",
            "finish": "\(finish)"
          }
        }

        Return the results in **JSON format**, structured as follows:

        {
          "food_pairings": {
            "dish_1": {
              "name": "",
              "ingredient_type": "", 
              "explanation": "Detailed reasoning on how this dish interacts with the wine's structure, acidity, tannins, and aromas."
            },
            "dish_2": {
              "name": "",
              "ingredient_type": "", 
              "explanation": ""
            },
            "dish_3": {
              "name": "",
              "ingredient_type": "", 
              "explanation": ""
            },
            "dish_4": {
              "name": "",
              "ingredient_type": "", 
              "explanation": ""
            },
            "dish_5": {
              "name": "",
              "ingredient_type": "", 
              "explanation": ""
            },
            "dish_6": {
              "name": "",
              "ingredient_type": "", 
              "explanation": ""
            }
          }
        }
        """
    }
    
    private func parseStep1Response(data: Data) throws -> WineInfo {
        do {
            // Try to print the raw JSON response for debugging
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("DEBUG: Step 1 Raw JSON response: \(jsonString)")
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("DEBUG: Failed to parse JSON from response")
                throw APIError.invalidResponse
            }
            
            // Extract content from the API response
            guard let choices = json["choices"] as? [[String: Any]], 
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("DEBUG: Invalid response structure: \(json)")
                throw APIError.invalidResponse
            }
            
            print("DEBUG: Content from response: \(content)")
            
            // Attempt to directly parse the content as a JSON object
            guard let contentData = content.data(using: .utf8),
                  let wineDetails = try? JSONSerialization.jsonObject(with: contentData, options: []) as? [String: Any] else {
                print("DEBUG: Failed to parse content as JSON")
                throw APIError.decodingError
            }
            
            print("DEBUG: Successfully parsed wine details: \(wineDetails)")
            
            // Create the WineInfo object manually from the dictionary
            var wineInfo = WineInfo(
                name: wineDetails["wine_name"] as? String ?? "Unknown Wine",
                winery: wineDetails["winery_producer"] as? String ?? "",
                region: wineDetails["region"] as? String ?? "",
                country: wineDetails["country"] as? String ?? "Unknown",
                vintage: wineDetails["vintage"] as? String,
                description: wineDetails["description"] as? String ?? "",
                subRegion: wineDetails["sub-region"] as? String,
                grapeVarieties: wineDetails["grape_varieties"] as? String,
                alcoholContent: wineDetails["alcohol_content"] as? String ?? "",
                wineStyleType: wineDetails["wine_style_type"] as? String ?? "",
                criticsScores: wineDetails["critics_scores"] as? String ?? "",
                whenToDrinkYear: wineDetails["when_to_drink_year"] as? String ?? "",
                decantingTime: wineDetails["decanting_time"] as? String ?? ""
            )
            
            // Parse tasting notes if available
            if let tastingNotesDict = wineDetails["tasting_notes"] as? [String: String] {
                wineInfo.tastingNotes = WineInfo.TastingNotes(
                    aroma: tastingNotesDict["aroma"] ?? "",
                    palate: tastingNotesDict["palate"] ?? "",
                    body: tastingNotesDict["body"] ?? "",
                    finish: tastingNotesDict["finish"] ?? ""
                )
            }
            
            print("DEBUG: Successfully created WineInfo object")
            return wineInfo
        } catch {
            print("DEBUG: Error in parseStep1Response: \(error)")
            throw error
        }
    }
    
    private func parseStep2Response(data: Data) throws -> WineInfo.FoodPairings {
        do {
            // Try to print the raw JSON response for debugging
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("DEBUG: Step 2 Raw JSON response: \(jsonString)")
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("DEBUG: Failed to parse JSON from response")
                throw APIError.invalidResponse
            }
            
            guard let choices = json["choices"] as? [[String: Any]], 
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("DEBUG: Invalid response structure: \(json)")
                throw APIError.invalidResponse
            }
            
            print("DEBUG: Content from response: \(content)")
            
            // Parse the JSON content directly
            guard let contentData = content.data(using: .utf8),
                  let jsonObject = try? JSONSerialization.jsonObject(with: contentData, options: []) as? [String: Any] else {
                print("DEBUG: Failed to parse content as JSON")
                throw APIError.decodingError
            }
            
            // Extract food pairings
            guard let foodPairingsDict = jsonObject["food_pairings"] as? [String: [String: String]] else {
                print("DEBUG: Invalid food pairing format")
                throw APIError.decodingError
            }
            
            var dishes: [WineInfo.FoodPairings.Dish] = []
            
            // Process each dish
            for (_, dishInfo) in foodPairingsDict {
                if let name = dishInfo["name"],
                   let ingredientType = dishInfo["ingredient_type"],
                   let explanation = dishInfo["explanation"] {
                    
                    let dish = WineInfo.FoodPairings.Dish(
                        name: name,
                        ingredientType: ingredientType,
                        explanation: explanation
                    )
                    dishes.append(dish)
                }
            }
            
            // If no dishes were parsed successfully, throw an error
            if dishes.isEmpty {
                print("DEBUG: No valid dishes found in the response")
                throw APIError.decodingError
            }
            
            return WineInfo.FoodPairings(dishes: dishes)
        } catch {
            print("DEBUG: Error in parseStep2Response: \(error)")
            throw error
        }
    }
    
    private func extractJSONFromString(_ string: String) -> Data? {
        print("DEBUG: Extracting JSON from string: \(string)")
        
        // Clean up the string - remove any markdown formatting if present
        var cleanString = string
        
        // Remove markdown code block markers
        cleanString = cleanString.replacingOccurrences(of: "```json", with: "")
        cleanString = cleanString.replacingOccurrences(of: "```", with: "")
        
        // Find JSON content between { and }
        if let startIndex = cleanString.firstIndex(of: "{"),
           let endIndex = cleanString.lastIndex(of: "}") {
            let jsonString = String(cleanString[startIndex...endIndex])
            print("DEBUG: Extracted JSON string: \(jsonString)")
            return jsonString.data(using: .utf8)
        }
        
        print("DEBUG: Could not find JSON delimiters in string")
        return nil
    }
} 

