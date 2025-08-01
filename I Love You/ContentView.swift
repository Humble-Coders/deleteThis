import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firebaseManager: RealFirebaseManager
    @State private var showingAddMemory = false
    @State private var showingSettings = false
    @State private var showingTodaySchedule = false

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
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

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Our Love Story")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text("Forever and always 💕")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 12) {
                            // Settings button
                            Button(action: {
                                showingSettings = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 44, height: 44)

                                    Image(systemName: "gearshape.fill")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                            }

                            // Add memory button
                            Button(action: {
                                showingAddMemory = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.pink, Color.purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                        .shadow(color: .pink.opacity(0.3), radius: 5, x: 0, y: 2)

                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Loading indicator
                    if firebaseManager.isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                            Text("Loading memories...")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        .padding()
                    }

                    // Error message
                    if !firebaseManager.errorMessage.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(firebaseManager.errorMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Button("Dismiss") {
                                firebaseManager.clearError()
                            }
                            .font(.caption)
                            .foregroundColor(.pink)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }

                    // Memories feed
                    if firebaseManager.memories.isEmpty && !firebaseManager.isLoading {
                        // Empty state
                        VStack(spacing: 20) {
                            Spacer()

                            Image(systemName: "heart.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.pink.opacity(0.5))

                            Text("No memories yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            Text("Tap the + button to add your first beautiful memory together")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            Button(action: {
                                showingAddMemory = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add First Memory")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.pink, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                            }

                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                LazyVStack(spacing: 16, pinnedViews: []) {
                                    // FreeTimeCard inside scroll feed
                                    FreeTimeCard {
                                        showingTodaySchedule = true
                                        HapticFeedback.shared.light()
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 12)
                                    .zIndex(1) // Ensure it doesn't overlap anything

                                    // All memory cards
                                    ForEach(firebaseManager.memories) { memory in
                                        NavigationLink(destination: MemoryDetailView(memory: memory)) {
                                            MemoryCard(memory: memory)
                                                .contentShape(Rectangle()) // Ensure tap area matches visible card
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.bottom, 100)
                            }
                        }
                        .refreshable {
                            firebaseManager.fetchMemories()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddMemory) {
            AddMemoryView()
        }
        .sheet(isPresented: $showingTodaySchedule) {
            TodayScheduleView()
        }
    }
}
