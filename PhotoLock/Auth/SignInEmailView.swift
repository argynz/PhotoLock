//
//  SignInEmailView.swift
//  PhotoLock
//
//  Created by Argyn on 17.09.2024.
//

import SwiftUI
import Firebase

final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter both email and password."
                self.showAlert = true
            }
            return
        }
        
        do {
            try await AuthManager.shared.createUser(email: email, password: password)
            
            if let user = AuthManager.shared.getCurrentUser() {
                try await user.sendEmailVerification()
                DispatchQueue.main.async {
                    self.errorMessage = "A verification link has been sent to your email. Please verify your email before signing in."
                    self.showAlert = true
                }
            }
        } catch {
            throw error
        }
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter both email and password."
                self.showAlert = true
            }
            return
        }
        
        do {
            try await AuthManager.shared.signInUser(email: email, password: password)
            
            if let user = AuthManager.shared.getCurrentUser(), !user.isEmailVerified {
                try AuthManager.shared.signOut()
                DispatchQueue.main.async {
                    self.errorMessage = "Please verify your email before signing in."
                    self.showAlert = true
                }
                return
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
            }
            throw error
        }
    }
}



struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .textInputAutocapitalization(.never)
                .signInTextFieldModifier()
            
            SecureField("Password...", text: $viewModel.password)
                .signInTextFieldModifier()
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        return
                    } catch {
                        print(error)
                    }
                    
                    do {
                        try await viewModel.signIn()
                        if !viewModel.showAlert{
                            showSignInView = false
                        }
                        return
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign In/ Sign Up")
                    .signInButtonStyle()
            }
            
            NavigationLink {
                ResetPasswordView()
            } label: {
                Text("Reset password")
                    .signInButtonStyle()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sigh In")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Info"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}


#Preview {
    NavigationStack {
        SignInEmailView(showSignInView: .constant(false))
    }
}
