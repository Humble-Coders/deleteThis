import SwiftUI

struct TodayScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    private let freeTimeManager = FreeTimeManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.pink.opacity(0.1),
                        Color.purple.opacity(0.1),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("📅")
                            .font(.system(size: 60))
                        
                        Text("\(todaySchedule?.dayName ?? "Today")'s Love Time")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Our free time together")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    if let schedule = todaySchedule, !schedule.slots.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(schedule.slots.enumerated()), id: \.offset) { index, slot in
                                    TimeSlotCard(slot: slot)
                                }
                                
                                // Footer message
                                VStack(spacing: 12) {
                                    HStack(spacing: 8) {
                                        ForEach(0..<5, id: \.self) { index in
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.pink.opacity(0.6))
                                                .font(.caption)
                                                .scaleEffect(index == 2 ? 1.2 : 1.0)
                                        }
                                    }
                                    
                                    Text("Perfect moments to be together!")
                                        .font(.subheadline)
                                        .foregroundColor(.pink)
                                        .italic()
                                }
                                .padding(.top, 16)
                            }
                            .padding(.horizontal, 20)
                        }
                    } else {
                        // No schedule today
                        VStack(spacing: 20) {
                            Text("😔")
                                .font(.system(size: 80))
                            
                            Text("No free time scheduled for today")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text("But we'll find time anyway! 💖")
                                .font(.body)
                                .foregroundColor(.pink)
                                .italic()
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.pink)
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private var todaySchedule: DaySchedule? {
        freeTimeManager.getTodaySchedule()
    }
}

struct TimeSlotCard: View {
    let slot: TimeSlot
    @State private var isCurrentSlot = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isCurrentSlot ?
                    LinearGradient(colors: [Color.pink.opacity(0.1), Color.purple.opacity(0.1)], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isCurrentSlot ? Color.pink : Color.gray.opacity(0.3),
                            lineWidth: isCurrentSlot ? 2 : 1
                        )
                )
            
            HStack(spacing: 16) {
                // Time indicator
                ZStack {
                    Circle()
                        .fill(isCurrentSlot ? Color.pink.opacity(0.2) : Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(isCurrentSlot ? "🟢" : "⏰")
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(slot.timeString)
                        .font(.headline)
                        .fontWeight(isCurrentSlot ? .bold : .semibold)
                        .foregroundColor(isCurrentSlot ? .pink : .primary)
                    
                    if isCurrentSlot {
                        Text("Currently active! 💕")
                            .font(.caption)
                            .foregroundColor(.pink)
                            .italic()
                    } else {
                        Text("Free time together")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isCurrentSlot {
                    VStack(spacing: 4) {
                        Text("✨")
                            .font(.title3)
                        
                        Text("NOW")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .onAppear {
            updateCurrentSlotStatus()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            updateCurrentSlotStatus()
        }
    }
    
    private func updateCurrentSlotStatus() {
        isCurrentSlot = slot.isCurrentlyActive()
    }
}

#Preview {
    TodayScheduleView()
}
