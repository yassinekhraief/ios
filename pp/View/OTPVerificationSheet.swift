import SwiftUI

struct OTPVerificationSheet: View {
    @Binding var otpText: String
    @Binding var isOtpVerified: Bool
    @State private var countdown = 60
    @State private var resendDisabled = true
    @ObservedObject var viewModel: OTPVerificationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Enter OTP")
                .font(.title)
                .fontWeight(.heavy)
                .padding(.top, 20)

            Text("A 6-digit code has been sent to your email.")
                .font(.callout)
                .foregroundColor(.gray)
                .padding(.top, -5)

            // OTP Text Box
            OTPVerificationView(otpText: $otpText)
                .padding(.top, 30)

            // OTP Verification Button
            Button(action: {
                viewModel.otp = otpText
                viewModel.verifyOtp()
                
                if viewModel.showPasswordField {
                    isOtpVerified = true
                    dismiss() // Dismiss the OTP verification sheet
                }
            }) {
                HStack {
                    Spacer()
                    Text("Verify")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(otpText.isEmpty)
            .opacity(otpText.isEmpty ? 0.5 : 1)

            if resendDisabled {
                Text("Resend OTP in \(countdown) seconds")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 15)
            } else {
                Button("Resend OTP") {
                    viewModel.generatedOtp = viewModel.generateNewOtp()
                    startCountdown()
                }
                .font(.callout)
                .foregroundColor(.blue)
                .padding(.top, 15)
            }
            Spacer()
        }
        .padding()
        .onAppear(perform: startCountdown)
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func startCountdown() {
        resendDisabled = true
        countdown = 60
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdown -= 1
            if countdown <= 0 {
                resendDisabled = false
                timer.invalidate()
            }
        }
    }
}

struct OTPVerificationSheet_Previews: PreviewProvider {
    static var previews: some View {
        OTPVerificationSheet(otpText: .constant(""), isOtpVerified: .constant(false), viewModel: OTPVerificationViewModel())
    }
}
