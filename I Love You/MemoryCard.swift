//
//  MemoryCard.swift
//  OurMemories
//
//  Clean memory card without swipe gestures - delete only in detail view
//

import SwiftUI

struct MemoryCard: View {
    let memory: Memory
    @EnvironmentObject var firebaseManager: RealFirebaseManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section with multiple image support
            ZStack {
                MultiImageMemoryView(
                    memory: memory,
                    width: UIScreen.main.bounds.width - 32,
                    height: 200,
                    cornerRadius: 20
                )
                
                // Gradient overlay for better text readability
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(20)
            }
            
            // Content section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(memory.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text(formatDate(memory.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Text(memory.displayDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(formatTimeFromDate(memory.date))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .font(.caption)
                        
                        Text("Beautiful Memory")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTimeFromDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: date, to: now)
        
        if let years = components.year, years > 0 {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        } else if let months = components.month, months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else {
            return "Today"
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(Memory.sampleMemories) { memory in
                MemoryCard(memory: memory)
            }
        }
        .padding(.vertical)
    }
    .environmentObject(RealFirebaseManager.shared)
    .preferredColorScheme(.light)
}
