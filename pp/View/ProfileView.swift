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
    @State private var navigateToPlacesView = false // State to trigger navigating to PlacesView
    
    let popularPlaces = ["france", "Germany", "Italy", "Spain", "Japan"] // List of popular places
    
    @State private var initialScrollDone = false // Track if initial scroll is done

    var body: some View {
        NavigationStack {
            ZStack {
                // Background image with blur effect
                Image("voyagee") // Replace with your image name
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 12) // Adjust the blur radius to your liking
                
                VStack {
                    // Welcome text and user email at the top (before the blurry photo)
                    VStack {
                        Text("Let's Explore!")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .padding(.top, 40)
                        
                        Text(userEmail)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .shadow(radius: 10)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 10)

                    // Container for buttons and carousel inside the rectangle
                    VStack(spacing: 20) { // Increased spacing between buttons for comfort
                        // Plan your trip button with an image
                        NavigationLink(destination: ChatBotView()) {
                            HStack {
                                Image(systemName: "airplane.departure") // You can replace with any image you like
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.cyan)
                                Text("Plan your trip")
                                    .font(.body) // Adjusted font size for readability
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 25)
                                    .background(LinearGradient(gradient: Gradient(colors: [.mint, .blue]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(30) // More rounded corners for a pill shape
                                    .shadow(radius: 5)
                                    .scaleEffect(1.05)
                                    .padding(20)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Translator button with an image
                        NavigationLink(destination: TranslatorView()) {
                            HStack {
                                Image(systemName: "book") // Icon added to Translator button
                                    .resizable()
                                    .frame(width: 22, height: 20)
                                    .foregroundColor(.cyan)
                                Text("  Translator")
                                    .font(.body) // Adjusted font size for readability
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 30)
                                    .background(LinearGradient(gradient: Gradient(colors: [.mint, .blue]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(30) // More rounded corners for a pill shape
                                    .shadow(radius: 5)
                                    .scaleEffect(1.05)
                                    .padding(20)
                            }
                        }
                        .padding(.horizontal, 50)
                        
                        // Go to Places button with an image
                        NavigationLink(destination: PlacesView(viewModel: PlaceViewModel(context: PersistenceController.shared.container.viewContext))) {
                            HStack {
                                Image(systemName: "map") // You can replace with any image you like
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.cyan)
                                Text("Go to Places")
                                    .font(.body) // Adjusted font size for readability
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 25)
                                    .background(LinearGradient(gradient: Gradient(colors: [.mint, .blue]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(30) // More rounded corners for a pill shape
                                    .shadow(radius: 5)
                                    .scaleEffect(1.1)
                                    .padding(20)
                            }
                        }
                        .padding(.horizontal, 80)
                        
                        // Popular Places Header
                        Text("Most Popular Places")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        // Carousel of images under the buttons (inside the rectangle)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(popularPlaces, id: \.self) { place in
                                    VStack {
                                        // Assuming images are named as "paris", "germany", etc.
                                        Image(place.lowercased()) // Replace with your asset names
                                            .resizable()
                                            .scaledToFill() // Adjust scaling to cover the view
                                            .frame(width: 150, height: 150) // Adjust size for better visibility
                                            .cornerRadius(10)
                                            .shadow(radius: 5)

                                        Text(place)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                            .padding(.top, 5)
                                    }
                                    .frame(width: 160)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .frame(height: 160) // Increased frame height to ensure all images are visible
                        .padding(.top, 20)
                    }
                    .background(
                        Color.white.opacity(0.4) // Slight transparent white overlay to make the content more readable
                            .cornerRadius(30)
                            .padding(.horizontal)
                    )
                    .padding(.all, 10)
                    .cornerRadius(30)
                    .padding(.bottom, 30)

                    Spacer()
                }
                
                // Profile Options Icon at the top-right corner with ZIndex
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showProfileOptions.toggle()  // Toggle the sheet to show options
                        }) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 70, height: 70) // Increased size for visibility
                                .foregroundColor(.blue)
                                .shadow(radius: 10)
                                .padding(20)
                        }
                        .accessibilityLabel("Profile Options") // Accessibility support
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
                    }
                    .padding(.top, 50) // Padding from top for profile icon to be aligned properly
                    .zIndex(1) // Ensure this button is on top of other layers
                }
            }

            // Navigation Links for Profile Options
            NavigationLink("", destination: LoginView(), isActive: $navigateToLogin)
                .hidden() // Programmatically trigger navigation to LoginView
            
            NavigationLink("", destination: UpdateProfileView(currentEmail: userEmail), isActive: $navigateToUpdateProfile)
                .hidden() // Programmatically trigger navigation to UpdateProfileView
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
