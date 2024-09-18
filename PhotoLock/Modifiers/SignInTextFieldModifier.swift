import SwiftUI

struct SignInTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
    }
}

extension View {
    func signInTextFieldModifier() -> some View {
        self.modifier(SignInTextFieldModifier())
    }
}
