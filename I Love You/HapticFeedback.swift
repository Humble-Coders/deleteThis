//
//  HapticFeedback.swift
//  OurMemories
//
//  Haptic feedback for better user experience
//

import SwiftUI
import UIKit

class HapticFeedback {
    static let shared = HapticFeedback()
    
    private init() {}
    
    // Light feedback for button taps
    func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // Medium feedback for actions
    func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // Heavy feedback for important actions
    func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    // Success feedback
    func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    // Warning feedback
    func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    // Error feedback
    func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}

// SwiftUI View extension for easy haptic feedback
extension View {
    func hapticFeedback(_ style: HapticStyle = .light) -> some View {
        self.onTapGesture {
            switch style {
            case .light:
                HapticFeedback.shared.light()
            case .medium:
                HapticFeedback.shared.medium()
            case .heavy:
                HapticFeedback.shared.heavy()
            case .success:
                HapticFeedback.shared.success()
            case .warning:
                HapticFeedback.shared.warning()
            case .error:
                HapticFeedback.shared.error()
            }
        }
    }
}

enum HapticStyle {
    case light, medium, heavy, success, warning, error
}
