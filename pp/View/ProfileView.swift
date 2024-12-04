import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: LoginViewModel  // ViewModel to access logged-in user's data
    
    // Fetch the saved email from UserDefaults
    var userEmail: String {
        return UserDefaults.standard.string(forKey: "user_email") ?? "No Email"
    }
    
    @State private var showProfileOptions = false  // State to manage showing profile options
    @State private var navigateToLogin = false     // State to trigger navigation to LoginView
    @State private var navigateToUpdateProfile = false // State to trigger navigating to the Update Profile view

    var body: some View {
        // Root NavigationStack for the Profile View
        NavigationStack {
            ZStack {
                // Subtle background color gradient
                LinearGradient(gradient: Gradient(colors: [Color.mint.opacity(0.6), Color.blue.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Welcome text and user email at the top (before the white rectangle)
                    VStack {
                        Text("Welcome!")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .shadow(radius: 10)
                            .padding(.top, 40)
                        
                        Text(userEmail)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.black.opacity(0.6))
                            .shadow(radius: 10)
                            .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)

                    // White rectangle containing buttons
                    VStack {
                        // Plan your trip button
                        NavigationLink(destination: ChatBotView()) {
                            Text("Plan your trip")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.mint, .blue]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(30)
                                .shadow(radius: 10)
                                .scaleEffect(1.05)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 90)
                        .padding(.top, 30)

                        Spacer()

                    }
                    .background(
                        Color.white.opacity(0.85) // Slightly opaque background for the profile options section
                            .cornerRadius(30)
                            .padding(.horizontal)
                    )
                    .padding(.all, 20)
                    .cornerRadius(30)

                    // Profile Options button (now below the white rectangle)
                    Button(action: {
                        showProfileOptions.toggle()  // Toggle the sheet to show options
                    }) {
                        Text("Profile Options")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [.mint, .blue]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(30)
                            .shadow(radius: 10)
                            .scaleEffect(1.05)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 60)

                    // Action Sheet for Profile Options
                    .actionSheet(isPresented: $showProfileOptions) {
                        ActionSheet(
                            title: Text("Profile Options"),
                            message: Text("What would you like to do?"),
                            buttons: [
                                .default(Text("Update Profile")) {
                                    navigateToUpdateProfile = true
                                },
                                .destructive(Text("Log Out")) {
                                    logOut()
                                },
                                .cancel()
                            ]	
                        )
                    }

                    // Navigation Links for Profile Options
                    NavigationLink("", destination: LoginView(), isActive: $navigateToLogin)
                        .hidden() // Programmatically trigger navigation to LoginView
                    
                    NavigationLink("", destination: UpdateProfileView(currentEmail: userEmail), isActive: $navigateToUpdateProfile)
                        .hidden() // Programmatically trigger navigation to UpdateProfileView
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Disable the default back button after logout
    }

    // Log out logic
    private func logOut() {
        // Remove saved user data from UserDefaults
        UserDefaults.standard.removeObject(forKey: "user_email")  // Remove email
        UserDefaults.standard.removeObject(forKey: "access_token")  // Remove access token

        // Update viewModel and logout status
        viewModel.isLoggedIn = false  // Log out the user in the view model

        // Trigger navigation to the login view
        navigateToLogin = true
        
        print("User logged out")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: LoginViewModel())  // Create a preview with a default LoginViewModel
            .previewDevice("iPhone 14")  // You can change this to preview on different devices
    }
}
 
