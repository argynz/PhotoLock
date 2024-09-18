//
//  AuthManager.swift
//  PhotoLock
//
//  Created by Argyn on 17.09.2024.
//

import Foundation
import FirebaseAuth

struct AuthResultModel {
    
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

final class AuthManager {
    
    static let shared = AuthManager()
    private init() { }
    
    func getCurrentUser() -> User? {
            return Auth.auth().currentUser
        }
    
    func getAuthUser() throws -> AuthResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthResultModel(user: user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

//MARK: SIGN IN EMAIL
extension AuthManager {
    
    @discardableResult
    func createUser(email: String, password: String) async throws ->  AuthResultModel {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthResultModel(user: authResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws ->  AuthResultModel {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthResultModel(user: authResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}

//MARK: SIGN IN GOOGLE
extension AuthManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws ->  AuthResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        let authResult = try await Auth.auth().signIn(with: credential)
        return AuthResultModel(user: authResult.user)
    }
}
