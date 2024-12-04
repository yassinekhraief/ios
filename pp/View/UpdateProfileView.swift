import SwiftUI

struct UpdateProfileView: View {
    @StateObject private var viewModel = UpdateProfileViewModel()  // ViewModel to handle profile update
    
    @Environment(\.dismiss) var dismiss  // Environment value to dismiss the view when update is successful
    
    // Accept current email to prepopulate fields or display it
    var currentEmail: String
    
    var body: some View {
        VStack {
            // Title
            Text("Update Profile")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Spacer()
            
            // Display current email (if necessary, for example to show the user their current email)
            Text("Current Email: \(currentEmail)")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            // New username input
            VStack {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    TextField("New Username", text: $viewModel.newUsername)  // Bind directly to viewModel's username
                        .autocapitalization(.none)
                        .padding()
                }
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // New password input
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    SecureField("New Password", text: $viewModel.newPassword)  // Bind directly to viewModel's password
                        .padding()
                }
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            
            // Error message (if any)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
            
            // Success message
            if viewModel.isSuccess {
                Text("Profile updated successfully!")
                    .foregroundColor(.green)
                    .padding(.top, 8)
            }
            
            // Update button
            Button(action: {
                viewModel.updateProfile()  // Now we don't need to pass parameters
            }) {
                Text(viewModel.isLoading ? "Updating..." : "Update Profile")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isLoading ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(viewModel.isLoading)  // Disable the button during loading
            
            Spacer()
            
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.mint.opacity(0.6), Color.blue.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all) // Ensures the background covers the whole screen
        )
        .onChange(of: viewModel.isSuccess) { success in
            if success {
                // Dismiss the view when the profile update is successful
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()  // This will navigate back to the previous screen (ProfileView)
                }
            }
        }
    }
}

struct UpdateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateProfileView(currentEmail: "user@example.com")
            .previewDevice("iPhone 14")
    }
}
