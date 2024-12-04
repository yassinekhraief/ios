import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()  // ViewModel to handle login
    @State private var isPasswordVisible = false  // State to toggle password visibility
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle background color gradient
                LinearGradient(gradient: Gradient(colors: [Color.mint.opacity(0.6), Color.blue.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all) // Ensures the gradient covers the entire screen
                
                VStack {
                    // Welcome text
                    VStack(alignment: .leading) {
                        Text("Welcome Back!")
                            .bold()
                            .font(.system(size: 30))
                            .padding(.bottom, 4)
                            .foregroundColor(Color.white)
                    }
                    
                    // Globe icon placeholder
                    VStack {
                        Image("mlk")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 150)
                            .padding()
                        
                        // Form fields for email and password
                        VStack(spacing: 24) {
                            // Email Input
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                                TextField("Email", text: $viewModel.email)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .padding()
                            }
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.mint, lineWidth: 2)
                                    .padding(.bottom, 5)  // Bottom border with mint color
                            )
                            
                            // Password Input
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                
                                // Show password or hide password based on isPasswordVisible state
                                if isPasswordVisible {
                                    TextField("Password", text: $viewModel.password)
                                        .padding()
                                } else {
                                    SecureField("Password", text: $viewModel.password)
                                        .padding()
                                }
                                
                                // Eye icon to toggle visibility of the password
                                Button(action: {
                                    isPasswordVisible.toggle()  // Toggle password visibility
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")  // Toggle icon
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 8)
                            }
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.mint, lineWidth: 2)
                                    .padding(.bottom, 5)  // Bottom border with mint color
                            )
                            
                            // Forgot Password link
                            HStack {
                                Spacer()  // Push the link to the right
                                NavigationLink(destination: ForgotPasswordView()) {
                                    Text("Forgot Password?")
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }
                            .padding(.top, 8)  // Add some space between password and link
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        // Error message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                        
                        // Sign in button
                        Button {
                            viewModel.login()  // Call login method from ViewModel
                        } label: {
                            Text(viewModel.isLoading ? "Loading..." : "SIGN IN")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.cyan)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.isLoading)  // Disable button during loading
                        .background(Color(.systemBlue))
                        .cornerRadius(30)
                        .padding(.top, 30)
                        .shadow(radius: 5)
                        
                        // Navigate to ProfileView after successful login
                        NavigationLink(destination: ProfileView(viewModel: viewModel), isActive: $viewModel.isLoggedIn) {
                            EmptyView()
                        }
                        .hidden()
                        
                        // Sign up prompt with only the "Sign up here" part clickable
                        HStack {
                            Text("Don't have an account?") // Static text
                                .foregroundColor(.black)
                            
                            // NavigationLink for the clickable "Sign up here"
                            NavigationLink(destination: SignUpView()) {
                                Text("Sign up here")
                                    .font(.footnote)  // Smaller font size
                                    .foregroundColor(.black)  // Black color for link
                                    .underline()  // Underline to make it look like a clickable link
                            }
                        }
                        .padding(.top, 20)  // Padding for spacing between login button and sign-up prompt
                        
                        Spacer()
                    }
                    .background(Color.white)
                    .padding(.all, 11)
                    .cornerRadius(60)
                    .padding(.horizontal)
                    
                }
            }
            .navigationBarBackButtonHidden(true)  // Hide the back button in LoginView

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
