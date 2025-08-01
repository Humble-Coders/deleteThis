import SwiftUI

struct FreeTimeCard: View {
    @StateObject private var freeTimeManager = FreeTimeManager.shared
    @State private var currentStatus: FreeTimeStatus = .noSchedule
    @State private var timer: Timer?
    @State private var isPressed = false
    
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
            HapticFeedback.shared.light()
        }) {
            // Beautiful card with improved inner UI
            RoundedRectangle(cornerRadius: 25)
                .fill(backgroundGradient)
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: strokeColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: shadowColor, radius: 20, x: 0, y: 10)
                .overlay(
                    // Glass effect overlay
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.clear,
                                    Color.black.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    // Main content
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(titleText)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text(subtitleText)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.95))
                                    .multilineTextAlignment(.leading)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()
                            
                            // Enhanced trailing section
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 50, height: 50)
                                        .blur(radius: 1)
                                    
                                    Text(trailingEmoji)
                                        .font(.system(size: 30))
                                        .shadow(color: .white.opacity(0.4), radius: 3, x: 0, y: 0)
                                }
                                
                                if !statusIndicator.isEmpty {
                                    Text(statusIndicator)
                                        .font(.caption)
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white.opacity(0.35),
                                                            Color.white.opacity(0.2)
                                                        ],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        
                        // Enhanced detail text with decorative elements
                        if !detailText.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(detailText)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.95))
                                    .italic()
                                    .multilineTextAlignment(.center)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 28)
                        }
                    }
                    .padding(.vertical, 24)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle()) // This ensures the entire card area is tappable
        .frame(maxWidth: .infinity) // Ensures full width coverage
        .onAppear {
            updateStatus()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func updateStatus() {
        currentStatus = freeTimeManager.getCurrentFreeTimeStatus()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            updateStatus()
        }
    }
    
    private var backgroundGradient: LinearGradient {
        switch currentStatus {
        case .currentlyFree:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.75),     // Medium pink
                    Color(red: 0.95, green: 0.4, blue: 0.7),     // Deeper pink
                    Color(red: 0.9, green: 0.35, blue: 0.65),    // Rich pink
                    Color(red: 1.0, green: 0.45, blue: 0.72)     // Medium pink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dayOver:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.6, blue: 0.5),      // Medium coral pink
                    Color(red: 0.95, green: 0.5, blue: 0.6),     // Deeper pink
                    Color(red: 0.9, green: 0.45, blue: 0.7),     // Rich pink
                    Color(red: 1.0, green: 0.55, blue: 0.65)     // Medium coral pink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nextSlotToday:
            return LinearGradient(
                colors: [
                    Color(red: 0.75, green: 0.5, blue: 0.95),    // Medium lavender
                    Color(red: 0.85, green: 0.45, blue: 0.9),    // Pink-lavender
                    Color(red: 0.95, green: 0.5, blue: 0.8),     // Medium pink
                    Color(red: 0.8, green: 0.48, blue: 0.92)     // Soft lavender-pink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nextSlotOtherDay:
            return LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.75, blue: 0.9),     // Medium blue-pink
                    Color(red: 0.7, green: 0.6, blue: 0.95),     // Medium lavender
                    Color(red: 0.9, green: 0.6, blue: 0.8),      // Medium pink
                    Color(red: 0.65, green: 0.7, blue: 0.88)     // Soft blue-pink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .noSchedule:
            return LinearGradient(
                colors: [
                    Color(red: 0.8, green: 0.65, blue: 0.85),    // Medium pink-gray
                    Color(red: 0.75, green: 0.7, blue: 0.9),     // Medium lavender-gray
                    Color(red: 0.9, green: 0.65, blue: 0.8),     // Medium pink
                    Color(red: 0.78, green: 0.68, blue: 0.86)    // Soft pink-lavender
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var strokeColors: [Color] {
        switch currentStatus {
        case .currentlyFree:
            return [Color.white.opacity(0.6), Color.pink.opacity(0.8)]
        case .dayOver:
            return [Color.white.opacity(0.6), Color.orange.opacity(0.8)]
        case .nextSlotToday:
            return [Color.white.opacity(0.6), Color.blue.opacity(0.8)]
        case .nextSlotOtherDay:
            return [Color.white.opacity(0.6), Color.green.opacity(0.8)]
        case .noSchedule:
            return [Color.white.opacity(0.4), Color.gray.opacity(0.6)]
        }
    }
    
    private var shadowColor: Color {
        switch currentStatus {
        case .currentlyFree:
            return Color.pink.opacity(0.4)
        case .dayOver:
            return Color.orange.opacity(0.4)
        case .nextSlotToday:
            return Color.blue.opacity(0.4)
        case .nextSlotOtherDay:
            return Color.green.opacity(0.4)
        case .noSchedule:
            return Color.gray.opacity(0.3)
        }
    }
    
    private var leadingEmoji: String {
        switch currentStatus {
        case .currentlyFree: return "💕"
        case .dayOver: return "🌅"
        case .nextSlotToday: return "⏰"
        case .nextSlotOtherDay: return "📅"
        case .noSchedule: return "💝"
        }
    }
    
    private var trailingEmoji: String {
        switch currentStatus {
        case .currentlyFree: return "✨"
        case .dayOver: return "🏠"
        case .nextSlotToday: return "💫"
        case .nextSlotOtherDay: return "🌟"
        case .noSchedule: return "💤"
        }
    }
    
    private var statusIndicator: String {
        switch currentStatus {
        case .currentlyFree:
            return formatCurrentDate()
        case .dayOver:
            return formatCurrentDate()
        case .nextSlotToday:
            return formatCurrentDate()
        case .nextSlotOtherDay(_, let dayName, let daysAhead):
            return formatFutureDate(dayName: dayName, daysAhead: daysAhead)
        case .noSchedule:
            return ""
        }
    }
    
    private func formatCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: Date())
    }
    
    private func formatFutureDate(dayName: String, daysAhead: Int) -> String {
        let futureDate = Calendar.current.date(byAdding: .day, value: daysAhead, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: futureDate)
    }
    
    private var titleText: String {
        switch currentStatus {
        case .currentlyFree:
            return "We're Both Free Now! 💖"
        case .dayOver:
            return "College is Over!"
        case .nextSlotToday:
            return "Next Free Time Today"
        case .nextSlotOtherDay(_, _, let daysAhead):
            return daysAhead == 1 ? "Next Free Tomorrow" : "Next Free Time"
        case .noSchedule:
            return "Schedule Loading..."
        }
    }
    
    private var subtitleText: String {
        switch currentStatus {
        case .currentlyFree(let slot, _):
            return slot.timeString
        case .dayOver:
            return "Time to be together before hostel! 🏠"
        case .nextSlotToday(let slot, _):
            return slot.timeString
        case .nextSlotOtherDay(let slot, let dayName, let daysAhead):
            return "\(slot.timeString)"
        case .noSchedule:
            return "Checking your schedule..."
        }
    }
    
    private var detailText: String {
        switch currentStatus {
        case .currentlyFree:
            return "Perfect time to spend together! 💖✨"
        case .dayOver:
            return "Enjoying our moments together! 💕"
        case .nextSlotToday:
            return "Looking forward to our time together! 🥰"
        case .nextSlotOtherDay:
            return "Can't wait to see you, my love! 💝"
        case .noSchedule:
            return ""
        }
    }
}

#Preview {
    VStack {
        FreeTimeCard {
            print("Tapped")
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}
