import SwiftUI
import GoogleGenerativeAI

let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)

// Add Unsplash API key
let unsplashAPIKey = "dxX8n-AfqAICDNcqYOOn7CDs5NPGKRP-47pqyyjtfw8" // Replace with your Unsplash API key

struct ChatBotView: View {
    @State private var messages: [Message] = []
    @State private var userInput = ""
    @State private var isLoading = false
    @State private var conversationContext = "" // Stores context for the conversation with Gemini API
    @State private var navigateToSuggestions = false
    @State private var suggestions: [PlaceSuggestion] = [] // Array to store AI-generated suggestions with images
    
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
                        suggestions: suggestions
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
        conversationContext = "" // Reset  aconversation context
        askingQuestion = "country"
    }
    
    func sendMessage() async {
        let userMessage = userInput
        userInput = ""  // Clear input field after capturing the input
        
        // Add the user's message to the chat
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
        Suggest travel destinations for a \(placeType) in \(country) that would be ideal for a trip of \(durationDays) days.
        """
        
        do {
            isLoading = true
            let response = try await model.generateContent(prompt)
            isLoading = false
            
            if let responseText = response.text {
                // Parse the response into place suggestions
                let placeNames = responseText.split(separator: "\n").map { String($0) }
                
                // Fetch images in parallel using TaskGroup
                let fetchedImages = await withTaskGroup(of: (String, String).self) { group in
                    var results: [(String, String)] = []
                    
                    for place in placeNames {
                        group.addTask {
                            let imageUrl = await fetchImageURL(for: place)
                            return (place, imageUrl)
                        }
                    }
                    
                    // Collect the results
                    for await result in group {
                        results.append(result)
                    }
                    
                    return results
                }
                
                // Map the fetched results to place suggestions
                suggestions = fetchedImages.map { PlaceSuggestion(name: $0.0, imageName: $0.1) }
                
                messages.append(Message(text: "Here are some destinations for you:", isUser: false))
                for suggestion in suggestions {
                    messages.append(Message(text: suggestion.name, isUser: false))
                }
                
                askingQuestion = "confirmation"
                isConfirmationRequired = true
            }
        } catch {
            isLoading = false
            messages.append(Message(text: "Failed to generate suggestions. Please try again.", isUser: false))
        }
    }
    
    func fetchImageURL(for place: String) async -> String {
        // Ensure the place name is URL-encoded to handle spaces and special characters
        let encodedPlace = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? place
        let urlString = "https://api.unsplash.com/photos/random?query=\(encodedPlace)&client_id=\(unsplashAPIKey)"
        
        print("Requesting Unsplash URL: \(urlString)") // Log the full request URL
        
        guard let url = URL(string: urlString) else {
            // Log and provide fallback behavior instead of crashing
            print("Error: Invalid Unsplash API URL for place: \(place)")
            return "https://via.placeholder.com/150" // Fallback image URL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Log the response data
            print("Received data from Unsplash API: \(String(data: data, encoding: .utf8) ?? "")")
            
            if let images = try? JSONDecoder().decode([UnsplashImage].self, from: data),
               let imageUrl = images.first?.urls.thumb { // Use smaller image version
                return imageUrl
            }
        } catch {
            // Log the error and provide a fallback image
            print("Error: Failed to fetch image for place: \(place), Error: \(error)")
        }
        
        // Fallback behavior if the image cannot be fetched
        return "https://via.placeholder.com/150" // Fallback image URL
    }

    func sendToBackend() {
        print("Sending details to backend...")
        navigateToSuggestions = true
    }
    
    struct Message: Identifiable {
        var id = UUID()
        var text: String
        var isUser: Bool
    }
    
    struct PlaceSuggestion: Identifiable {
        var id = UUID()
        var name: String
        var imageName: String
    }
    
    struct UnsplashImage: Decodable {
        var urls: UnsplashImageURLs
    }
    
    struct UnsplashImageURLs: Decodable {
        var thumb: String // Fetch a smaller version
    }
    
    struct SuggestionsView: View {
        var country: String
        var travelDate: String
        var durationDays: String
        var placeType: String
        var suggestions: [PlaceSuggestion]
        
        var body: some View {
            ScrollView {
                ForEach(suggestions) { suggestion in
                    VStack {
                        AsyncImage(url: URL(string: suggestion.imageName)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // Show loading spinner
                                    .frame(maxHeight: .infinity)
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 200)
                            case .failure:
                                Image(systemName: "photo") // Show a placeholder icon if the image fails to load
                                    .resizable()
                                    .frame(height: 200)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        Text(suggestion.name)
                            .font(.headline)
                            .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle("Suggestions")
        }
    }
}

struct ChatBotViewPreview: PreviewProvider {
    static var previews: some View {
        ChatBotView()
    }
}
