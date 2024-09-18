//
//  ResetPasswordView.swift
//  PhotoLock
//
//  Created by Argyn on 17.09.2024.
//

import SwiftUI
import FirebaseAuth

final class ResetPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var alertMessage = ""
    @Published var showResetPasswordAlert = false
    @Published var showAlert = false
    
        func resetPassword() async throws {
            guard !email.isEmpty else {
                print("No email provided.")
                return
            }
    
            try await AuthManager.shared.resetPassword(email: email)
        }
}

struct ResetPasswordView: View {
    @StateObject private var viewModel = ResetPasswordViewModel()
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .textInputAutocapitalization(.never)
                .signInTextFieldModifier()
            
            Button {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        viewModel.alertMessage = "Link for resetting the password has been sent to your email."
                    } catch {
                        viewModel.alertMessage = "The email address is badly formatted."
                        print(error)
                    }
                    viewModel.showAlert = true
                }
            } label: {
                Text("Reset")
                    .signInButtonStyle()
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Reset The Password")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Info"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ResetPasswordView()
}
