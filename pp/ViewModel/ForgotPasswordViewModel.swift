import SwiftUI

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""  // User's email for password reset
    @Published var errorMessage: String? = nil  // To show error messages
    @Published var successMessage: String? = nil  // To show success message
    @Published var isLoading = false  // To track the loading state
    @Published var navigateToResetPassword = false  // State to trigger navigation
    
    private let resetPasswordURL = URL(string: "https://b641-160-157-2-134.ngrok-free.app/user/forgot-password")!  // Replace with your actual URL
    
    // Function to reset the password
    func resetPassword() {
        // Check if the email is valid
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        // Reset the error and success messages
        errorMessage = nil
        successMessage = nil
        
        isLoading = true
        
        // Prepare the request body
        let parameters = ["email": email]
        
        // Create the request
        var request = URLRequest(url: resetPasswordURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert parameters to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            errorMessage = "Failed to encode request data."
            isLoading = false
            return
        }
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    // Handle the error response from the server
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                // Handle the response from the server
                guard let data = data else {
                    self.errorMessage = "No data received from the server."
                    return
                }
                
                // Check the response status
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        // Success - OTP sent
                        self.successMessage = "OTP sent to your email!"
                        
                        // Trigger navigation to reset password view
                        self.navigateToResetPassword = true  // Set this state to trigger navigation
                    } else {
                        // Failure
                        self.errorMessage = "Failed to send reset email. Please try again. Code: \(httpResponse.statusCode)"
                    }
                } else {
                    self.errorMessage = "Invalid response from the server."
                }
            }
        }.resume()  // Start the network request
    }
    
    // Simple email validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "(?:[A-Za-z0-9]+(?:[.-_]?[A-Za-z0-9]+)*@(?:[A-Za-z0-9]+(?:[.-_]?[A-Za-z0-9]+)*\\.)+[A-Za-z]{2,})"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
