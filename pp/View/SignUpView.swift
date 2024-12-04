import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()  // The ViewModel is responsible for handling the signup logic
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var isPasswordVisible = false // New state variable to control password visibility
    @State private var isConfirmPasswordVisible = false // New state variable to control confirm password visibility
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text("Let's Start your Journey together!")
                        .font(.system(size: 20, weight: .bold)) // Adjust font size here
                        .padding(.bottom, 20) // Padding to give some space between the title and image
                    
                    // Add your image here
                    Image("mlk") // Replace "your_image_name" with your image asset name
                        .resizable()
                        .scaledToFit() // Adjust image to fit within the frame
                        .frame(width: 200, height: 200) // Set the size of the image
                        .padding(.bottom, 30) // Add some space below the image
                    
                    // Text Fields for SignUp form
                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.mint, lineWidth: 2)
                                    .padding(.bottom, 5)
                            )
                        
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.mint, lineWidth: 2)
                                    .padding(.bottom, 5)
                            )
                        
                        // Password field with show/hide toggle inside the label
                        ZStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.mint, lineWidth: 2)
                                            .padding(.bottom, 5)
                                    )
                            } else {
                                SecureField("Password", text: $password)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.mint, lineWidth: 2)
                                            .padding(.bottom, 5)
                                    )
                            }
                            
                            // Eye icon inside the text field label
                            HStack {
                                Spacer()
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                        }
                        
                        // Confirm Password field with show/hide toggle inside the label
                        ZStack {
                            if isConfirmPasswordVisible {
                                TextField("Confirm Password", text: $confirmPassword)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.mint, lineWidth: 2)
                                            .padding(.bottom, 5)
                                    )
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.mint, lineWidth: 2)
                                            .padding(.bottom, 5)
                                    )
                            }
                            
                            // Eye icon inside the text field label
                            HStack {
                                Spacer()
                                Button(action: {
                                    isConfirmPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                        }
                    }
                    .padding(.top, 50)

                    // Sign Up Button
                    Button(action: {
                        // Set the view model's properties to match the input from the form
                        viewModel.email = email
                        viewModel.username = username
                        viewModel.password = password
                        viewModel.confirmPassword = confirmPassword

                        // Call the signUp method in the view model to handle the signup logic
                        viewModel.signUp()
                    }) {
                        Text("Create Account")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mint)
                            .cornerRadius(8)
                    }
                    .padding(.top, 30)

                    Spacer()

                    // Show error or success message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    if let successMessage = viewModel.successMessage {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .padding()
                    }

                    // Sign In Link (NavigationLink)
                    NavigationLink(destination: LoginView()) {  // Navigate to LoginView here
                        Text("Already have an account? Sign In")
                            .font(.footnote)
                            .foregroundColor(.mint)
                            .padding(.top, 20)
                    }
                }
                .cornerRadius(16)
                .padding()
            }
            .navigationBarBackButtonHidden(true)  // Hide the back button in SignUpView
            .navigationTitle("")  // Optionally, remove the default navigation title
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
