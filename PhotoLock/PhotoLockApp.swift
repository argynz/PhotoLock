import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct PhotoLockApp: App {
    
    init() {
        FirebaseApp.configure()
        print("Firebase configured!")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
