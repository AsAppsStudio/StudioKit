#if canImport(SwiftUI) && canImport(StoreKit)
import StoreKit
import SwiftUI

public extension View {
    /// Shows the system rating sheet 1 s after `trigger` becomes `true`, then resets it.
    /// Set `trigger` from `ReviewPrompt.recordSuccess(_:)` or from an explicit "Rate" button.
    func studioReviewPrompt(on trigger: Binding<Bool>) -> some View {
        modifier(StudioReviewPromptModifier(trigger: trigger))
    }
}

struct StudioReviewPromptModifier: ViewModifier {
    @Binding var trigger: Bool
    @Environment(\.requestReview) private var requestReview

    func body(content: Content) -> some View {
        content.onChange(of: trigger) { _, fire in
            guard fire else { return }
            Task { @MainActor in
                // Let the host's success animation and haptic finish first.
                try? await Task.sleep(for: .seconds(1))
                requestReview()
                trigger = false
            }
        }
    }
}
#endif
