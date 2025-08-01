//
//  ImageGalleryView.swift
//  OurMemories
//
//  Swipeable image gallery with full screen support
//

import SwiftUI

struct ImageGalleryView: View {
    let memory: Memory
    let width: CGFloat
    let height: CGFloat
    @State private var currentImageIndex = 0
    @State private var showingFullScreen = false
    
    init(memory: Memory, width: CGFloat = 350, height: CGFloat = 300) {
        self.memory = memory
        self.width = width
        self.height = height
        self._currentImageIndex = State(initialValue: memory.thumbnailImageIndex)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !memory.imageUrls.isEmpty {
                // Main image carousel
                TabView(selection: $currentImageIndex) {
                    ForEach(memory.imageUrls.indices, id: \.self) { index in
                        AsyncImageView(
                            imageUrl: memory.imageUrls[index],
                            fallbackIcon: memory.imageName,
                            width: width,
                            height: height,
                            imageSize: .large
                        )
                        .tag(index)
                        .onTapGesture {
                            HapticFeedback.shared.light()
                            showingFullScreen = true
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(width: width, height: height)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Custom page indicator (only show if multiple images)
                if memory.hasMultipleImages {
                    HStack(spacing: 8) {
                        ForEach(memory.imageUrls.indices, id: \.self) { index in
                            Circle()
                                .fill(currentImageIndex == index ? Color.pink : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentImageIndex == index ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentImageIndex)
                        }
                    }
                    .padding(.top, 12)
                }
                
                // Image counter
                if memory.hasMultipleImages {
                    Text("\(currentImageIndex + 1) of \(memory.imageUrls.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            } else if let imageName = memory.imageName {
                // SF Symbol fallback
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.4), Color.purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: width, height: height)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: imageName)
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
            }
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            FullScreenImageView(
                memory: memory,
                startingIndex: currentImageIndex,
                onIndexChange: { newIndex in
                    currentImageIndex = newIndex
                }
            )
        }
    }
}

// MARK: - Full Screen Image Viewer
struct FullScreenImageView: View {
    let memory: Memory
    @State private var currentIndex: Int
    let onIndexChange: (Int) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    
    init(memory: Memory, startingIndex: Int = 0, onIndexChange: @escaping (Int) -> Void) {
        self.memory = memory
        self._currentIndex = State(initialValue: startingIndex)
        self.onIndexChange = onIndexChange
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            if !memory.imageUrls.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(memory.imageUrls.indices, id: \.self) { index in
                        AsyncImage(url: URL(string: memory.imageUrls[index])) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    SimultaneousGesture(
                                        // Pinch to zoom
                                        MagnificationGesture()
                                            .onChanged { value in
                                                scale = max(0.5, min(3.0, value))
                                            }
                                            .onEnded { _ in
                                                withAnimation(.spring()) {
                                                    if scale < 1.0 {
                                                        scale = 1.0
                                                        offset = .zero
                                                    }
                                                }
                                            },
                                        
                                        // Drag to pan (when zoomed)
                                        DragGesture()
                                            .onChanged { value in
                                                if scale > 1.0 {
                                                    offset = value.translation
                                                }
                                            }
                                            .onEnded { _ in
                                                if scale <= 1.0 {
                                                    withAnimation(.spring()) {
                                                        offset = .zero
                                                    }
                                                }
                                            }
                                    )
                                )
                                .onTapGesture(count: 2) {
                                    // Double tap to zoom
                                    withAnimation(.spring()) {
                                        if scale > 1.0 {
                                            scale = 1.0
                                            offset = .zero
                                        } else {
                                            scale = 2.0
                                        }
                                    }
                                    HapticFeedback.shared.medium()
                                }
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(2.0)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentIndex) { newIndex in
                    onIndexChange(newIndex)
                    // Reset zoom when changing images
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scale = 1.0
                        offset = .zero
                    }
                }
            }
            
            // Controls overlay
            VStack {
                // Top controls
                HStack {
                    Button("Done") {
                        HapticFeedback.shared.light()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(25)
                    
                    Spacer()
                    
                    if memory.hasMultipleImages {
                        Text("\(currentIndex + 1) / \(memory.imageUrls.count)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(25)
                    }
                }
                .padding()
                
                Spacer()
                
                // Bottom controls (page indicators for multiple images)
                if memory.hasMultipleImages {
                    HStack(spacing: 12) {
                        ForEach(memory.imageUrls.indices, id: \.self) { index in
                            Circle()
                                .fill(currentIndex == index ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 10, height: 10)
                                .scaleEffect(currentIndex == index ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentIndex)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .gesture(
            // Single tap to show/hide controls
            TapGesture()
                .onEnded { _ in
                    HapticFeedback.shared.light()
                }
        )
        .statusBarHidden()
    }
}

#Preview {
    ImageGalleryView(
        memory: Memory.sampleMemories[0]
    )
}
