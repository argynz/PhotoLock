import SwiftUI

struct SignInButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
    }
}

extension View {
    func signInButtonStyle() -> some View {
        self.modifier(SignInButtonModifier())
    }
}
