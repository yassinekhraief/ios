import Foundation

class ResetPasswordViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private var email: String = ""
    private var otpText: String = ""
    
    // Set email and OTP once the OTP is verified
    func setCredentials(email: String, otpText: String) {
        self.email = email
        self.otpText = otpText
    }

    // Reset password method that now interacts with the backend
    func resetPassword(newPassword: String) {
        // Ensure email, OTP, and newPassword are not empty
        guard !email.isEmpty, !otpText.isEmpty, !newPassword.isEmpty else {
            errorMessage = "All fields are required."
            return
        }

        // Create the request payload
        let resetPasswordDto = ResetPasswordDto(email: email, otp: otpText, newPassword: newPassword)
        
        // Start loading
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Make the network request
        guard let url = URL(string: "https://7dc7-160-157-2-134.ngrok-free.app/user/reset-password") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Convert the resetPasswordDto into JSON
            let jsonData = try JSONEncoder().encode(resetPasswordDto)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Error encoding data"
            isLoading = false
            return
        }
        
        // Create the data task
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Request failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                // Handle the response from the backend
                do {
                    // Try to decode the response (assuming it returns a success message)
                    let response = try JSONDecoder().decode(ResetPasswordResponse.self, from: data)
                    self?.successMessage = response.message
                } catch {
                    self?.errorMessage = "Failed to parse response"
                }
            }
        }
        
        task.resume()
    }
}

// Model for request data
struct ResetPasswordDto: Codable {
    let email: String
    let otp: String
    let newPassword: String
}

// Model for the response (Assuming your backend sends a success message)
struct ResetPasswordResponse: Codable {
    let message: String
}
