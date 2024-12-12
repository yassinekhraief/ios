import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    private let signupURL = URL(string: "https://c3f1-196-236-142-123.ngrok-free.app/user/signup")!

    func signUp() {
        // Debugging print statement
        print("signUp() called with email: \(email), username: \(username), password: \(password), confirmPassword: \(confirmPassword)")
        
        guard !email.isEmpty, !username.isEmpty, !password.isEmpty, password == confirmPassword else {
            self.errorMessage = "Please fill in all fields and make sure the passwords match."
            self.successMessage = nil  // Reset success message
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil  // Reset error message

        let parameters = [
            "email": email,
            "username": username,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            self.errorMessage = "Failed to create request data."
            self.successMessage = nil  // Reset success message
            return
        }
        
        var request = URLRequest(url: signupURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    self.successMessage = nil
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 201 {
                        self.errorMessage = "Server error: \(httpResponse.statusCode)"
                        self.successMessage = nil
                        return
                    }
                }

                guard let data = data else {
                    self.errorMessage = "No data received."
                    self.successMessage = nil
                    return
                }

                do {
                    let responseObject = try JSONDecoder().decode(SignUpResponse.self, from: data)
                    self.successMessage = "Your account has been created successfully!"
                    self.errorMessage = nil
                    
                    // Debugging print statement
                    print("Sign up successful: \(responseObject)")
                } catch {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    self.successMessage = nil
                }
            }
        }.resume()
    }

    struct SignUpResponse: Decodable {
        let email: String
        let username: String
        let _id: String
        let __v: Int
    }
}
