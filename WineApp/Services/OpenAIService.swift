import Foundation
import UIKit

enum APIError: Error {
    case requestFailed(String)
    case invalidResponse
    case decodingError
}

class OpenAIService {
    
    func analyzeWineImage(imageData: Data) async throws -> WineInfo {
        guard let base64Image = convertImageToBase64(imageData: imageData) else {
            print("DEBUG: Failed to convert image to base64")
            throw APIError.requestFailed("Failed to convert image to base64")
        }
        
        let prompt = createWineAnalysisPrompt()
        
        let requestBody: [String: Any] = [
            "model": APIConfig.openAIModel,
            "messages": [
                [
                    "role": "system",
                    "content": prompt
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Please analyze this wine bottle and provide detailed information about the wine."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1500,
            "temperature": 0.5 // Lower temperature for more consistent responses
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
            
            return try parseResponse(data: data)
        } catch {
            print("DEBUG: Network request error: \(error)")
            throw error
        }
    }
    
    private func convertImageToBase64(imageData: Data) -> String? {
        return imageData.base64EncodedString()
    }
    
    private func createWineAnalysisPrompt() -> String {
        return """
        You are a wine expert and sommelier with deep knowledge of all wine regions, vintages, and styles.
        
        Your task is to analyze the wine bottle image and extract detailed information about the wine. I want you to return ONLY a JSON object with the following structure:
        
        {
          "name": "Full wine name as shown on the bottle",
          "winery": "Producer/winery name",
          "vintage": "Year of harvest (e.g., 2018)",
          "region": "Wine region or appellation",
          "country": "Country of origin",
          "grapeVarieties": "List of grape varieties used",
          "tastingNotes": "Detailed description of flavor profile, body, acidity, tannins, and finish",
          "foodPairings": "Suggested food pairings for this wine",
          "criticsScore": "Any available critics scores (e.g., 92 points Wine Spectator)",
          "agingPotential": "How long the wine can be aged",
          "additionalInfo": "Any other relevant information like historical context or special production methods"
        }
        
        Rules:
        1. DO NOT include any text before or after the JSON object
        2. DO NOT use markdown code blocks (```) around the JSON
        3. Use VALID JSON syntax - use double quotes for all keys and string values
        4. If you cannot determine a particular detail from the image, make an educated guess based on your knowledge but indicate uncertainty in the value (e.g., "Likely Cabernet Sauvignon, but label unclear")
        5. Provide comprehensive analysis for tastingNotes and foodPairings
        6. Never leave any field empty - use educated guesses when information is not visible
        7. If the vintage is unclear, estimate it based on the apparent age and style of the bottle
        
        Your analysis should showcase deep wine expertise through the detailed information provided in the JSON fields. Remember: respond ONLY with the JSON object, nothing else.
        """
    }
    
    private func parseResponse(data: Data) throws -> WineInfo {
        do {
            // Try to print the raw JSON response for debugging
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("DEBUG: Raw JSON response: \(jsonString)")
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
            
            // Extract the JSON content from the response
            guard let jsonData = extractJSONFromString(content) else {
                print("DEBUG: Failed to extract JSON from content")
                throw APIError.decodingError
            }
            
            do {
                // First, try direct decoding
                let decoder = JSONDecoder()
                
                do {
                    let wineInfo = try decoder.decode(WineInfo.self, from: jsonData)
                    print("DEBUG: Successfully decoded WineInfo: \(wineInfo.name)")
                    return wineInfo
                } catch let decodingError {
                    print("DEBUG: Initial decoding error: \(decodingError)")
                    
                    // If direct decoding fails, try to clean up the JSON
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("DEBUG: Attempting to clean up JSON: \(jsonString)")
                        
                        // Try parsing as Dictionary and manually constructing WineInfo
                        if let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            print("DEBUG: Successfully parsed as dictionary, attempting to create WineInfo manually")
                            
                            // Extract values manually
                            let name = jsonDict["name"] as? String ?? "Unknown Wine"
                            let winery = jsonDict["winery"] as? String
                            let vintage = jsonDict["vintage"] as? String
                            let region = jsonDict["region"] as? String
                            let country = jsonDict["country"] as? String ?? ""
                            
                            // Try different potential key names for grape varieties
                            var grapeVarieties: String? = nil
                            for key in ["grapeVarieties", "grapeVariety", "grape", "grapes", "varieties"] {
                                if let value = jsonDict[key] as? String, !value.isEmpty {
                                    grapeVarieties = value
                                    break
                                }
                            }
                            
                            let alcoholContent = jsonDict["alcoholContent"] as? String ?? ""
                            let style = jsonDict["style"] as? String ?? ""
                            
                            // Try different potential key names for tasting notes
                            var tastingNotes: String? = nil
                            for key in ["tastingNotes", "tasting", "tastingNote", "notes"] {
                                if let value = jsonDict[key] as? String, !value.isEmpty {
                                    tastingNotes = value
                                    break
                                }
                            }
                            
                            // Try different potential key names for food pairings
                            var foodPairings: String? = nil
                            for key in ["foodPairings", "foodPairing", "pairing", "pairings"] {
                                if let value = jsonDict[key] as? String, !value.isEmpty {
                                    foodPairings = value
                                    break
                                }
                            }
                            
                            let criticsScore = jsonDict["criticsScore"] as? String ?? ""
                            let agingPotential = jsonDict["agingPotential"] as? String ?? ""
                            
                            // Try different potential key names for additional info
                            var additionalInfo: String? = nil
                            for key in ["additionalInfo", "additional", "info", "description"] {
                                if let value = jsonDict[key] as? String, !value.isEmpty {
                                    additionalInfo = value
                                    break
                                }
                            }
                            
                            // Create WineInfo object manually
                            return WineInfo(
                                name: name,
                                winery: winery,
                                vintage: vintage,
                                region: region,
                                country: country,
                                grapeVarieties: grapeVarieties,
                                alcoholContent: alcoholContent,
                                style: style,
                                tastingNotes: tastingNotes,
                                foodPairings: foodPairings,
                                criticsScore: criticsScore,
                                agingPotential: agingPotential,
                                additionalInfo: additionalInfo
                            )
                        }
                    }
                    
                    // If we got here, both attempts failed
                    print("DEBUG: All decoding attempts failed")
                    throw APIError.decodingError
                }
            } catch {
                print("DEBUG: Error in parseResponse: \(error)")
                throw error
            }
        } catch {
            print("DEBUG: Error in parseResponse: \(error)")
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