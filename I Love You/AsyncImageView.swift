//
//  AsyncImageView.swift
//  OurMemories
//
//  Enhanced image view with Cloudinary optimization and caching
//

import SwiftUI

// Define our custom ImageSize enum to avoid conflicts
enum MemoryImageSize {
    case thumbnail  // 150x150
    case medium     // 400x300
    case large      // 800x600
    case original   // Full size
}

struct AsyncImageView: View {
    let imageUrl: String?
    let fallbackIcon: String?
    let width: CGFloat
    let height: CGFloat
    let imageSize: MemoryImageSize
    
    @State private var isLoading = true
    
    init(imageUrl: String?, fallbackIcon: String? = nil, width: CGFloat = 100, height: CGFloat = 100, imageSize: MemoryImageSize = .medium) {
        self.imageUrl = imageUrl
        self.fallbackIcon = fallbackIcon
        self.width = width
        self.height = height
        self.imageSize = imageSize
    }
    
    var body: some View {
        Group {
            if let imageUrl = imageUrl, !imageUrl.isEmpty {
                let optimizedUrl = getOptimizedUrl(imageUrl, for: imageSize)
                
                AsyncImage(url: URL(string: optimizedUrl)) { phase in
                    switch phase {
                    case .empty:
                        // Loading state
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.pink.opacity(0.1), Color.purple.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: width, height: height)
                            
                            VStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                                    .scaleEffect(0.8)
                                
                                Text("Loading...")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .transition(.opacity)
                        
                    case .success(let image):
                        // Successfully loaded image
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: height)
                            .clipped()
                            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                        
                    case .failure(_):
                        // Failed to load - show fallback
                        fallbackView
                        
                    @unknown default:
                        fallbackView
                    }
                }
            } else {
                // No URL provided - show fallback
                fallbackView
            }
        }
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var fallbackView: some View {
        if let fallbackIcon = fallbackIcon {
            // SF Symbol fallback
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: height)
                
                Image(systemName: fallbackIcon)
                    .font(.system(size: min(width, height) * 0.4))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        } else {
            // Default placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: width, height: height)
                
                VStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.system(size: min(width, height) * 0.25))
                        .foregroundColor(.gray)
                    
                    Text("No Image")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // Simple URL optimization function
    private func getOptimizedUrl(_ url: String, for size: MemoryImageSize) -> String {
        // For now, just return the original URL
        // You can add Cloudinary transformations here later
        return url
    }
}

// MARK: - Multi-Image Memory View
struct MultiImageMemoryView: View {
    let memory: Memory
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let showImageCount: Bool
    
    init(memory: Memory, width: CGFloat = 300, height: CGFloat = 200, cornerRadius: CGFloat = 12, showImageCount: Bool = true) {
        self.memory = memory
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.showImageCount = showImageCount
    }
    
    var body: some View {
        ZStack {
            // Display thumbnail image
            if let thumbnailUrl = memory.thumbnailImageUrl {
                AsyncImageView(
                    imageUrl: thumbnailUrl,
                    fallbackIcon: memory.imageName,
                    width: width,
                    height: height,
                    imageSize: determineImageSize()
                )
            } else if let imageName = memory.imageName {
                // SF Symbol fallback
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: width, height: height)
                    
                    Image(systemName: imageName)
                        .font(.system(size: min(width, height) * 0.3))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                }
            } else {
                // No image fallback
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: width, height: height)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: min(width, height) * 0.25))
                            .foregroundColor(.pink.opacity(0.6))
                        
                        Text("Beautiful Memory")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Multiple images indicator (small circle)
            if memory.hasMultipleImages && showImageCount {
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 28, height: 28)
                            
                            Text("\(memory.imageUrls.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                        .padding(.trailing, 8)
                    }
                    
                    Spacer()
                }
            }
            
            // Subtle overlay for better text readability
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(cornerRadius)
        }
        .cornerRadius(cornerRadius)
    }
    
    private func determineImageSize() -> MemoryImageSize {
        let area = width * height
        
        if area <= 30000 {
            return .thumbnail
        } else if area <= 150000 {
            return .medium
        } else {
            return .large
        }
    }
}

// MARK: - Compatibility Alias
typealias MemoryImageView = MultiImageMemoryView

#Preview {
    VStack {
        AsyncImageView(
            imageUrl: "https://example.com/image.jpg",
            fallbackIcon: "heart.fill",
            width: 200,
            height: 150
        )
        
        MultiImageMemoryView(
            memory: Memory.sampleMemories[0],
            width: 300,
            height: 200
        )
    }
}
