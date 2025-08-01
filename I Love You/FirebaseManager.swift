//
//  FirebaseManager.swift
//  OurMemories
//
//  Updated Firebase manager with Cloudinary integration
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private let cloudinary = CloudinaryManager.shared
    
    @Published var memories: [Memory] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var uploadProgress: Double = 0.0
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        signInAnonymously()
    }
    
    private func signInAnonymously() {
        auth.signInAnonymously { [weak self] result, error in
            if let error = error {
                self?.errorMessage = "Authentication failed: \(error.localizedDescription)"
            } else {
                print("✅ Signed in anonymously")
                self?.fetchMemories()
            }
        }
    }
    
    // MARK: - Memory Operations
    
    func fetchMemories() {
        guard auth.currentUser != nil else { return }
        
        isLoading = true
        
        firestore.collection("memories")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to fetch memories: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    DispatchQueue.main.async {
                        self?.memories = []
                    }
                    return
                }
                
                let fetchedMemories = documents.compactMap { document -> Memory? in
                    do {
                        return try document.data(as: Memory.self)
                    } catch {
                        print("❌ Failed to decode memory: \(error)")
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    self?.memories = fetchedMemories
                    print("✅ Fetched \(fetchedMemories.count) memories")
                }
            }
    }
    
    func addMemory(_ memory: Memory, image: UIImage?) async {
        guard auth.currentUser != nil else { return }
        
        await MainActor.run {
            isLoading = true
            uploadProgress = 0.0
        }
        
        do {
            var memoryToSave = memory
            let memoryId = UUID().uuidString
            memoryToSave.id = memoryId
            
            // Upload image to Cloudinary if provided
            if let image = image {
                await MainActor.run {
                    uploadProgress = 0.3
                }
                
                print("📤 Uploading image to Cloudinary...")
                let imageUrl = try await cloudinary.uploadImage(image, memoryId: memoryId)
                memoryToSave.imageUrl = imageUrl
                print("✅ Image uploaded: \(imageUrl)")
                
                await MainActor.run {
                    uploadProgress = 0.7
                }
            }
            
            // Save memory to Firestore
            print("💾 Saving memory to Firestore...")
            try firestore.collection("memories").document(memoryId).setData(from: memoryToSave)
            print("✅ Memory saved to Firestore")
            
            await MainActor.run {
                isLoading = false
                uploadProgress = 1.0
            }
            
            // Give haptic feedback for success
            HapticFeedback.shared.success()
            
        } catch {
            print("❌ Failed to save memory: \(error)")
            await MainActor.run {
                isLoading = false
                uploadProgress = 0.0
                if let cloudinaryError = error as? CloudinaryError {
                    errorMessage = cloudinaryError.localizedDescription
                } else {
                    errorMessage = "Failed to save memory: \(error.localizedDescription)"
                }
            }
            
            // Give haptic feedback for error
            HapticFeedback.shared.error()
        }
    }
    
    func deleteMemory(_ memory: Memory) async {
        guard auth.currentUser != nil,
              let memoryId = memory.id else { return }
        
        do {
            // Delete image from Cloudinary if exists
            if let imageUrl = memory.imageUrl {
                try await cloudinary.deleteImage(from: imageUrl)
                print("🗑️ Image deleted from Cloudinary")
            }
            
            // Delete from Firestore
            try await firestore.collection("memories").document(memoryId).delete()
            print("✅ Memory deleted from Firestore")
            
            // Give haptic feedback
            HapticFeedback.shared.success()
            
        } catch {
            print("❌ Failed to delete memory: \(error)")
            await MainActor.run {
                errorMessage = "Failed to delete memory: \(error.localizedDescription)"
            }
            
            HapticFeedback.shared.error()
        }
    }
    
    func clearError() {
        errorMessage = ""
    }
    
    // MARK: - Image URL Optimization
    
    func optimizedImageUrl(_ url: String, for size: ImageSize = .medium) -> String {
        switch size {
        case .thumbnail:
            return cloudinary.thumbnailUrl(from: url)
        case .medium:
            return cloudinary.optimizedUrl(from: url, width: 400, height: 300)
        case .large:
            return cloudinary.optimizedUrl(from: url, width: 800, height: 600)
        case .original:
            return url
        }
    }
}

// MARK: - Image Size Options
enum ImageSize {
    case thumbnail  // 150x150
    case medium     // 400x300
    case large      // 800x600
    case original   // Full size
}
