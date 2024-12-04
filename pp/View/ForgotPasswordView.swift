import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()  // Initialize the ViewModel
    
    var body: some View {
        NavigationStack {  // Use NavigationStack to manage navigation
            VStack {
                Text("Forgot Password?")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                Spacer()
                
                Text("Enter your email to reset your password.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // Email input for password reset
                TextField("Email", text: $viewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
                
                // Success message
                if let successMessage = viewModel.successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding(.top, 8)
                }
                
                // Reset button
                Button(action: {
                    viewModel.resetPassword()  // Call the reset password function in the ViewModel
                }) {
                    Text(viewModel.isLoading ? "Resetting..." : "Reset Password")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isLoading || viewModel.email.isEmpty)  // Disable if loading or no email entered
                
                // Navigate to ResetPasswordView if OTP is successfully sent
                NavigationLink(
                    destination: ResetPasswordView(),  // Change this to your ResetPasswordView
                    isActive: $viewModel.navigateToResetPassword,  // Bind to viewModel's state
                    label: { EmptyView() }  // The NavigationLink itself is invisible
                )
                
                Spacer()
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.mint.opacity(0.6), Color.blue.opacity(0.5)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
            .padding()
        }
        .onAppear {
            // Make sure we clear previous errors when view appears
            viewModel.errorMessage = nil
            viewModel.successMessage = nil
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
