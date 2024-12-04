import SwiftUI

class OTPVerificationViewModel: ObservableObject {
    @Published var otp: String = "" // The OTP entered by the user
    @Published var errorMessage: String = "" // For error messages
    @Published var showError: Bool = false // To show errors
    @Published var showPasswordField: Bool = false // Whether to show the password reset form
    var generatedOtp: String = "" // The OTP sent to the user
    
    // Function to verify OTP
    func verifyOtp() {
        guard !otp.isEmpty else {
            errorMessage = "OTP is required."
            showError = true
            return
        }
        
        // Simulating OTP verification. You would replace this with an API call
        if otp == generatedOtp {
            showPasswordField = true // OTP verified, show password field
        } else {
            errorMessage = "Invalid OTP."
            showError = true
        }
    }
    
    // Function to generate a new OTP
    func generateNewOtp() -> String {
        let newOtp = String((0..<6).map { _ in "0123456789".randomElement()! })
        return newOtp
    }
}
