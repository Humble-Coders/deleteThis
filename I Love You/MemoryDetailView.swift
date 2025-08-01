//  MemoryDetailView.swift
//  OurMemories
//
//  Enhanced full screen view with image gallery and sharing
//

import SwiftUI

struct MemoryDetailView: View {
    let memory: Memory
    @EnvironmentObject var firebaseManager: RealFirebaseManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingShareSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingStoryPopup = false
    @State private var selectedStory: StoryDetails? = nil
    
    var body: some View {
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
            
            ScrollView {
                VStack(spacing: 30) {
                    // Large image gallery section with action buttons overlay
                    ZStack {
                        ImageGalleryView(
                            memory: memory,
                            width: UIScreen.main.bounds.width - 32,
                            height: 300
                        )
                        
                        // Action buttons overlay
                        VStack {
                            HStack {
                                Spacer()
                                
                                VStack(spacing: 12) {
                                    // Share button
                                    Button(action: {
                                        HapticFeedback.shared.light()
                                        showingShareSheet = true
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.9))
                                                .frame(width: 44, height: 44)
                                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                            
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.title3)
                                                .foregroundColor(.pink)
                                        }
                                    }
                                    
                                    // Delete button
                                    Button(action: {
                                        HapticFeedback.shared.warning()
                                        showingDeleteAlert = true
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.9))
                                                .frame(width: 44, height: 44)
                                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                            
                                            Image(systemName: "trash")
                                                .font(.title3)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    // Content
                    VStack(spacing: 24) {
                        // Title and date
                        VStack(spacing: 12) {
                            Text(memory.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                            
                            HStack(spacing: 20) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.pink)
                                    
                                    Text(formatDate(memory.date))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.purple)
                                    
                                    Text(formatTimeFromDate(memory.date))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.pink.opacity(0.1))
                            )
                        }
                        
                        // Story section with two-sided story support
                        storySection
                        
                        // Decorative elements
                        VStack(spacing: 16) {
                            HStack(spacing: 20) {
                                ForEach(0..<5) { index in
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.pink.opacity(0.6))
                                        .font(.title3)
                                        .scaleEffect(index == 2 ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(Double(index) * 0.2), value: index)
                                }
                            }
                            
                            Text("A beautiful moment in our love story")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .italic()
                        }
                        .padding(.top, 8)
                        
                        // Memory stats
                        VStack(spacing: 12) {
                            HStack {
                                VStack {
                                    Text("💕")
                                        .font(.title)
                                    Text("Love")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("📅")
                                        .font(.title)
                                    Text("\(daysSince(memory.date)) days ago")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text(memory.hasMultipleImages ? "📸" : "🖼️")
                                        .font(.title)
                                    Text(memory.hasMultipleImages ? "\(memory.imageUrls.count) photos" : "1 photo")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("✨")
                                        .font(.title)
                                    Text("Special")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.pink.opacity(0.05))
                            .cornerRadius(16)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            
            // Story Popup Overlay
            if showingStoryPopup, let story = selectedStory {
                StoryPopupView(
                    story: story,
                    isShowing: $showingStoryPopup
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingStoryPopup)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    HapticFeedback.shared.light()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.pink)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(memory: memory)
        }
        .alert("Delete Memory", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                HapticFeedback.shared.light()
            }
            Button("Delete", role: .destructive) {
                HapticFeedback.shared.heavy()
                Task {
                    await firebaseManager.deleteMemory(memory)
                    await MainActor.run {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(memory.title)'? This beautiful memory will be lost forever.")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
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
    
    private func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        return max(0, components.day ?? 0)
    }
    
    // MARK: - Story Section
    @ViewBuilder
    private var storySection: some View {
        if memory.hasTwoSidedStory {
            twoSidedStoryView
        } else if !memory.description.isEmpty {
            singleStoryView
        }
    }
    
    @ViewBuilder
    private var twoSidedStoryView: some View {
        VStack(alignment: .leading, spacing: 20) {
            storyHeader
            
            HStack(spacing: 16) {
                if let myStory = memory.myStory {
                    hisStoryCard(myStory)
                }
                
                if let herStory = memory.herStory {
                    herStoryCard(herStory)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private var singleStoryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            storyHeader
            
            Text(memory.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private var storyHeader: some View {
        HStack {
            Text("Our Story")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundColor(.pink)
                .font(.title3)
        }
    }
    
    @ViewBuilder
    private func hisStoryCard(_ myStory: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                Text("His Side")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .font(.caption)
                    .foregroundColor(.blue.opacity(0.6))
            }
            
            Text(myStory)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text("Tap to read full story")
                    .font(.caption)
                    .foregroundColor(.blue.opacity(0.7))
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            selectedStory = StoryDetails(
                title: "His Side",
                content: myStory,
                color: .blue,
                emoji: "💙"
            )
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showingStoryPopup = true
            }
            HapticFeedback.shared.light()
        }
    }
    
    @ViewBuilder
    private func herStoryCard(_ herStory: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.pink)
                    .frame(width: 12, height: 12)
                Text("Her Side")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .font(.caption)
                    .foregroundColor(.pink.opacity(0.6))
            }
            
            Text(herStory)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text("Tap to read full story")
                    .font(.caption)
                    .foregroundColor(.pink.opacity(0.7))
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.pink.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.pink.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            selectedStory = StoryDetails(
                title: "Her Side",
                content: herStory,
                color: .pink,
                emoji: "💖"
            )
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showingStoryPopup = true
            }
            HapticFeedback.shared.light()
        }
    }
}

// MARK: - Story Details Model
struct StoryDetails {
    let title: String
    let content: String
    let color: Color
    let emoji: String
}

// MARK: - Story Popup View
struct StoryPopupView: View {
    let story: StoryDetails
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isShowing = false
                    }
                    HapticFeedback.shared.light()
                }
            
            // Popup content
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    // Handle bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 6)
                    
                    // Title with emoji
                    HStack(spacing: 12) {
                        Text(story.emoji)
                            .font(.title)
                        
                        Text(story.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(story.color)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isShowing = false
                            }
                            HapticFeedback.shared.light()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray.opacity(0.6))
                        }
                    }
                    
                    // Decorative divider
                    HStack {
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(story.color.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                
                // Story content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(story.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(8)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Decorative hearts at the bottom
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 8) {
                                ForEach(0..<3) { index in
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(story.color.opacity(0.6))
                                        .font(.caption)
                                        .scaleEffect(index == 1 ? 1.2 : 1.0)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(story.color.opacity(0.1), lineWidth: 2)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let memory: Memory
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let text = """
        💕 \(memory.title)
        
        \(memory.description)
        
        Date: \(formatDate(memory.date))
        
        From our love story app 💖
        """
        
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        MemoryDetailView(memory: Memory.sampleMemories[0])
            .environmentObject(RealFirebaseManager.shared)
    }
}
