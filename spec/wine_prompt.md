# Step1

## Settings
* text_format=json_object
* temperature = 0.2
* top_p = 0.3
* max_tokens = 500-700

## Prompt
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
  "when_to_drink_year": ""  // Return only numeric years (e.g., "2024-2030"), no additional text.
}

# Step2

## Settings
* text_format=json_object
* temperature = 0.8
* top_p = 0.9
* max_tokens = 800-1000

## Prompt

Based on the following wine details, generate **creative and well-balanced food pairings** that complement its flavor profile. Provide at least 6 pairings covering meats, seafood, vegetables, cheeses, appetizers, and desserts.

{
  "wine_name": "[Insert Wine Name]",
  "country": "",
  "region": "",
  "sub-region": "",
  "grape_varieties": "[Insert Grapes]",
  "tasting_notes": {
    "aroma": "[Insert Aroma]",
    "palate": "[Insert Palate]",
    "body": "[Insert Body]",
    "finish": "[Insert Finish]"
  }
}

Return the results in **JSON format**, structured as follows:

{
  "food_pairings": {
    "dish_1": {
      "name": "",
      "ingredient_type": "", 
      "explanation": "Detailed reasoning on how this dish interacts with the wine’s structure, acidity, tannins, and aromas."
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