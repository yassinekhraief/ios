import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var resetPasswordViewModel = ResetPasswordViewModel()
    @State private var otpText: String = ""
    @State private var isOtpVerified: Bool = false
    @State private var showOtpSheet: Bool = true // Show OTP sheet initially
    @State private var email: String = ""
    @State private var newPassword: String = ""
    
    var body: some View {
        VStack {
            if isOtpVerified {
                // Once OTP is verified, show email and password fields
                Text("Reset Your Password")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)

                // Email TextField
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)

                // New Password TextField
                SecureField("Enter new password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // Show Error or Success messages
                if let errorMessage = resetPasswordViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                if let successMessage = resetPasswordViewModel.successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                }

                // Reset Password Button
                Button(action: {
                    // Call resetPassword without passing OTP and newPassword directly
                    resetPasswordViewModel.resetPassword(newPassword: newPassword)
                }) {
                    Text(resetPasswordViewModel.isLoading ? "Resetting..." : "Reset Password")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(resetPasswordViewModel.isLoading ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(resetPasswordViewModel.isLoading || newPassword.isEmpty)
                .padding(.top, 20)
            }
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground)) // For visual appearance
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showOtpSheet) {
            OTPVerificationSheet(otpText: $otpText, isOtpVerified: $isOtpVerified, viewModel: OTPVerificationViewModel())
        }
        .onAppear {
            // Set the credentials in the ViewModel once OTP is verified
            if isOtpVerified {
                resetPasswordViewModel.setCredentials(email: email, otpText: otpText)
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
	
