import SwiftUI
import GoogleGenerativeAI

let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)

struct ChatBotView: View {
    @State private var messages: [Message] = []
    @State private var userInput = ""
    @State private var isLoading = false
    @State private var conversationContext = "" // Stores context for the conversation with Gemini API
    @State private var navigateToSuggestions = false
    @State private var suggestions: [String] = []  // Array to store the AI-generated suggestions
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
                
                // NavigationLink for transitioning to SuggestionsView
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
        conversationContext = "" // Reset conversation context
        askingQuestion = "country"
    }
    
    func sendMessage() async {
        let userMessage = userInput
        userInput = ""  // Clear input field after capturing the input
        
        // Add the user's message to the chat
        messages.append(Message(text: userMessage, isUser: true))
        
        // Update the appropriate state variable based on the current question
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
        
        // Show loading spinner while waiting for AI's response or moving to the next question
        isLoading = true
        
        do {
            // Simulate AI response logic
            isLoading = false // Turn off loading state
            await handleConversation(responseText: userMessage)
        } catch {
            // Handle errors, if any
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
            
            // Generate places using the AI model
            await generatePlaces()
        }
    }
    
    func generatePlaces() async {
        let prompt = """
        Suggest 3 travel destinations for a \(placeType) in \(country) that would be ideal for a trip of \(durationDays) days. \
        Provide brief descriptions for each destination.
        """
        
        do {
            isLoading = true
            // Call the AI model with the constructed prompt
            let response = try await model.generateContent(prompt)
            isLoading = false
            
            if let responseText = response.text {
                // Split the response into suggestions
                suggestions = responseText.split(separator: "\n").map { String($0) }
                
                // Display AI suggestions as chat messages
                messages.append(Message(text: "Here are some \(placeType) destinations for you:", isUser: false))
                for suggestion in suggestions {
                    messages.append(Message(text: suggestion, isUser: false))
                }
                
                // Proceed to confirmation
                askingQuestion = "confirmation"
                isConfirmationRequired = true
            }
        } catch {
            isLoading = false
            messages.append(Message(text: "Failed to generate suggestions. Please try again.", isUser: false))
        }
    }
    
    func sendToBackend() {
        print("Sending the following information to the backend:")
        print("Country: \(country)")
        print("Travel Date: \(travelDate)")
        print("Duration: \(durationDays) days")
        print("Type of Place: \(placeType)")
        
        // Send dynamic suggestions to the backend
        suggestions.forEach { suggestion in
            print(suggestion)
        }
        
        // Trigger navigation to the suggestions view
        navigateToSuggestions = true
    }
    
    struct Message: Identifiable {
        var id = UUID()
        var text: String
        var isUser: Bool
    }
    
    struct ChatBotViewPreview: PreviewProvider {
        static var previews: some View {
            ChatBotView()
        }
    }
}
