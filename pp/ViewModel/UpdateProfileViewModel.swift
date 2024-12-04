import SwiftUI

class UpdateProfileViewModel: ObservableObject {
    @Published var newUsername: String = ""  // New username entered by the user
    @Published var newPassword: String = ""  // New password entered by the user
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isSuccess: Bool = false

    private let updateProfileURL = URL(string: "https://b641-160-157-2-134.ngrok-free.app/user/update")! // Ngrok URL

    struct UserProfileResponse: Decodable {
        struct Data: Decodable {
            let _id: String
            let email: String
            let password: String
            let username: String
            let __v: Int
        }

        let data: Data
    }

    func updateProfile() {
        guard !newUsername.isEmpty, !newPassword.isEmpty else {
            self.errorMessage = "Both username and password must be provided."
            return
        }
        
        self.isLoading = true
        
        // Construct the URL request
        var request = URLRequest(url: updateProfileURL)
        request.httpMethod = "PATCH" // or whatever method you are using
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the body data as JSON
        let requestBody: [String: Any] = [
            "username": newUsername,
            "password": newPassword
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            self.errorMessage = "Failed to encode request body."
            self.isLoading = false
            return
        }

        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Stop loading spinner
                self.isLoading = false
                
                // Check for errors
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                // Check the HTTP response status code
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        self.errorMessage = "Server error: \(httpResponse.statusCode)"
                        return
                    }
                }
                
                // Ensure we have data to process
                guard let data = data else {
                    self.errorMessage = "No data received."
                    return
                }
                
                // Print the raw response to inspect it
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(jsonString)")
                }
                
                // Try to decode the response into a UserProfileResponse
                do {
                    let userProfileResponse = try JSONDecoder().decode(UserProfileResponse.self, from: data)
                    self.isSuccess = true
                    self.errorMessage = nil
                    print("Updated Profile: \(userProfileResponse)") // You can inspect the response here
                } catch {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

}
