import SwiftUI

struct OTPVerificationView: View {
    @Binding var otpText: String // This will bind to the OTP text entered by the user
    @FocusState private var isKeyboardShowing: Bool // State for controlling focus on the keyboard
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<6, id: \.self) { index in
                OTPTextBox(index)
            }
        }
        .background {
            // Hidden TextField for managing focus and interacting with the keyboard
            TextField("", text: $otpText.limit(6)) // Ensures OTP doesn't exceed 6 characters
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode) // Helps with auto-filling OTP
                .frame(width: 1, height: 1)
                .opacity(0) // Hide the TextField
                .focused($isKeyboardShowing)
        }
        .contentShape(Rectangle()) // Makes the entire area tappable to trigger the keyboard
        .onTapGesture {
            isKeyboardShowing = true
        }
    }
    
    // OTP Text Box for each digit
    @ViewBuilder
    private func OTPTextBox(_ index: Int) -> some View {
        ZStack {
            if otpText.count > index {
                let charToString = String(otpText[otpText.index(otpText.startIndex, offsetBy: index)])
                Text(charToString)
                    .font(.system(size: 22)) // Customize font size for the OTP digits
            } else {
                Text(" ") // Display a blank space for empty OTP fields
                    .font(.system(size: 22))
            }
        }
        .frame(width: 45, height: 45) // Adjust the frame size for each OTP field
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.gray, lineWidth: 0.5) // Border around the OTP field
        }
    }
}

extension Binding where Value == String {
    // Helper to limit the OTP text to 6 characters
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}
