import SwiftUI
import GoogleGenerativeAI

let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)

import Foundation

struct TravelDestination: Identifiable, Codable {
    var id = UUID() // Unique ID for Identifiable conformance
    var destination: String
    var description: String
    var imageUrl: String

    enum CodingKeys: String, CodingKey {
        case destination
        case description
        case imageUrl = "image" // Mapping "image" from the JSON to imageUrl in the model
    }
}


struct TravelSuggestion: Identifiable {
    let id = UUID() // Add a unique identifier
    let destination: String
    let description: String
    let imageUrl: String? // Nullable imageUrl for cases where no image is provided
}


// Message model used for chat or feedback
struct Message: Identifiable {
    var id = UUID()
    var text: String
    var isUser: Bool
}

struct ChatBotView: View {
    @State private var messages: [Message] = []
    @State private var userInput = ""
    @State private var isLoading = false
    @State private var conversationContext = "" // Stores context for the conversation with Gemini API
    @State private var navigateToSuggestions = false
    @State private var suggestions: [TravelSuggestion] = []  // Array to store the AI-generated suggestions
    // State to store the user's travel details
    @State private var country: String = ""
    @State private var travelDate: String = ""
    @State private var durationDays: String = ""
    @State private var placeType: String = ""
    
    @State private var isConfirmationRequired = false // Flag to determine if confirmation is required
    @State private var confirmationMessage: String = "" // To store the confirmation message
    @State private var askingQuestion = "" // To track which question we are currently asking
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: 300, alignment: .trailing)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .frame(maxWidth: 300, alignment: .leading)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    }
                    
                    if isConfirmationRequired {
                        VStack {
                            Text("Please confirm your details before we proceed:")
                                .font(.headline)
                                .padding()
                            
                            Text("Country: \(country)")
                            Text("Travel Date: \(travelDate)")
                            Text("Duration: \(durationDays) days")
                            Text("Type of Place: \(placeType)")
                            
                            Button("Confirm") {
                                sendToBackend()
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(suggestions) { suggestion in
                                VStack {
                                    Text(suggestion.destination)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.top, 8)
                                        .padding(.horizontal)
                                        .multilineTextAlignment(.center)
                                    
                                    Text(suggestion.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 200, height: 120)
                                        .padding([.leading, .bottom, .trailing], 8)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                    
                                    if let imageUrl = suggestion.imageUrl, let fixedUrl = fixUrl(imageUrl) {
                                        AsyncImage(url: fixedUrl) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle())
                                                    .frame(width: 200, height: 120)
                                            case .success(let image):
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(width: 200, height: 120)
                                                    .cornerRadius(10)
                                                    .clipped()
                                            case .failure:
                                                Text("Failed to load image")
                                                    .foregroundColor(.red)
                                            @unknown default:
                                                Text("Unknown state")
                                            }
                                        }
                                        .padding([.leading, .bottom, .trailing], 8)
                                    }
                                }
                                .padding(.leading)
                            }
                        }
                    }
                    .padding(.top)
                }
                
                Divider()
                
                HStack {
                    TextField("Type your answer...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        Task {
                            await sendMessage()
                        }
                    }) {
                        Text("Send")
                            .bold()
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.trailing)
                    .disabled(userInput.isEmpty)
                }
                
                NavigationLink(
                    destination: SuggestionsView(
                        country: country,
                        travelDate: travelDate,
                        durationDays: durationDays,
                        placeType: placeType,
                        suggestions: suggestions.map { $0.destination }
                    ),
                    isActive: $navigateToSuggestions
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Travel Chat")
        }
        .onAppear {
            startConversation()
        }
    }
    
    func startConversation() {
        let initialMessage = "Hi! Let's plan your trip. Where would you like to go?"
        messages.append(Message(text: initialMessage, isUser: false))
        conversationContext = ""
        askingQuestion = "country"
    }
    
    func sendMessage() async {
        let userMessage = userInput
        userInput = ""
        messages.append(Message(text: userMessage, isUser: true))
        
        switch askingQuestion {
        case "country":
            country = userMessage
        case "date":
            travelDate = userMessage
        case "duration":
            durationDays = userMessage
        case "placeType":
            placeType = userMessage
        default:
            break
        }
        
        isLoading = true
        
        do {
            isLoading = false
            await handleConversation(responseText: userMessage)
        } catch {
            isLoading = false
            messages.append(Message(text: "Sorry, something went wrong. Please try again.", isUser: false))
        }
    }
    
    func handleConversation(responseText: String) async {
        if askingQuestion == "country" {
            country = responseText
            askingQuestion = "date"
            messages.append(Message(text: "When would you like to travel?", isUser: false))
        } else if askingQuestion == "date" {
            travelDate = responseText
            askingQuestion = "duration"
            messages.append(Message(text: "How many days will your trip be?", isUser: false))
        } else if askingQuestion == "duration" {
            durationDays = responseText
            askingQuestion = "placeType"
            messages.append(Message(text: "What type of place do you prefer to visit (e.g., beach, mountains, city)?", isUser: false))
        } else if askingQuestion == "placeType" {
            placeType = responseText
            askingQuestion = "generatePlaces"
            messages.append(Message(text: "Generating places based on your preferences...", isUser: false))
            await generatePlaces()
        }
    }
    
    func generatePlaces() async {
        let prompt = """
        Suggest \(durationDays) travel destinations for a \(placeType) in \(country) that would be ideal for a trip of \(durationDays) days. Provide a brief description and include an image URL for each day of the trip in valid JSON format. Use the following format for the image URL:
        "https://image.pollinations.ai/prompt/generate%20an%20image%20of%20{destination}" where {destination} is the name of the travel destination.

        Each destination should have the following format:

        [
          {
            "day": 1,
            "destination": "Destination Name",
            "description": "A brief description of the destination for this day.",
            "image": "https://image.pollinations.ai/prompt/generate%20an%20image%20of%20Destination Name"
          },
          ...
        ]
        """



        
        
        do {
            isLoading = true
            let response = try await model.generateContent(prompt)
            isLoading = false

            if let responseText = response.text {
                print("AI Response: \(responseText)") // Log raw AI response

                // Check if the response is valid JSON and attempt to decode
                if let data = responseText.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    let destinations = try decoder.decode([TravelDestination].self, from: data)

                    suggestions = destinations.map { TravelSuggestion(destination: $0.destination, description: $0.description, imageUrl: $0.imageUrl) }

                    askingQuestion = "confirmation"
                    isConfirmationRequired = true
                } else {
                    print("Failed to convert response to Data.")
                }
            } else {
                print("No response from the AI.")
                messages.append(Message(text: "No response from the AI. Please try again.", isUser: false))
            }
        } catch {
            isLoading = false
            print("Error generating content: \(error.localizedDescription)")
            messages.append(Message(text: "Failed to generate suggestions. Please try again.", isUser: false))
        }
    }


    
    func fixUrl(_ urlString: String) -> URL? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return nil
        }
        print("valid URL string: \(urlString)")
        return url
    }

    func sendToBackend() {
        print("Sending the following information to the backend:")
        print("Country: \(country)")
        print("Travel Date: \(travelDate)")
        print("Duration: \(durationDays) days")
        print("Type of Place: \(placeType)")
        
        suggestions.forEach { suggestion in
            print(suggestion)
        }
        
        navigateToSuggestions = true
    }

    struct ChatBotViewPreview: PreviewProvider {
        static var previews: some View {
            ChatBotView()
        }
    }
}
