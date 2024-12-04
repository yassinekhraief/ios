import Combine
import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String? = nil
    @Published var accessToken: String? = nil
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // URL for login endpoint
    private let loginURL = URL(string: "https://ea8c-197-3-6-252.ngrok-free.app/user/login")!
    
    // Call the login function
    func login() {
        // Validate input
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            isLoggedIn = false
            return
        }
        
        // Create parameters for the login request
        let parameters = [
            "email": email,
            "password": password
            
        ]
        
        // Call the function to perform the login request
        performLoginRequest(parameters: parameters)
    }
    
    private func performLoginRequest(parameters: [String: String]) {
        // Prepare the URL request
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Serialize the login parameters to JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Failed to encode login data."
            isLoggedIn = false
            return
        }
        
        // Set loading state to true while the request is in progress
        isLoading = true
        
        // Perform the network request using Combine's dataTaskPublisher
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                // Ensure we have a valid HTTPURLResponse
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                // Handle the response status code
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    // If the response code is OK (2xx), return the data
                    return data
                } else {
                    // If the response is not OK, throw an error
                    throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: ["message": "Server error: \(httpResponse.statusCode)"])
                }
            }
            .decode(type: LoginResponse.self, decoder: JSONDecoder()) // Decode the response to a LoginResponse object
            .receive(on: DispatchQueue.main) // Ensure UI updates happen on the main thread
            .sink { completion in
                switch completion {
                case .failure(let error):
                    // Handle failure scenario
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                    self.isLoggedIn = false
                    self.isLoading = false
                case .finished:
                    break
                }
            } receiveValue: { response in
                // Log the entire response object for debugging
                print("Decoded response object: \(response)")  // Log the parsed response
                
                // Handle successful login response
                if let token = response.access_token {
                    print("Access token: \(token)") // Log the access token
                    
                    // Save the access token to UserDefaults (or better: Keychain for security)
                    UserDefaults.standard.set(token, forKey: "access_token")
                    
                    // Save the email to UserDefaults (or Keychain if you want more security)
                    UserDefaults.standard.set(self.email, forKey: "user_email")
                    
                    // Update login status
                    self.isLoggedIn = true
                    self.errorMessage = nil
                    self.isLoading = false
                } else {
                    // Handle failed login (no access token returned)
                    self.isLoggedIn = false
                    self.errorMessage = "Login failed: No access token received"
                    self.isLoading = false
                }
            }
            .store(in: &cancellables) // Store the subscription to manage memory
    }
}

struct LoginResponse: Decodable {
    let access_token: String?  // Only the access_token field, which is optional
}
