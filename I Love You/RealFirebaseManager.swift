
//  RealFirebaseManager.swift
//  OurMemories
//
//  Complete Firebase + Cloudinary integration with real-time sync
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore

class RealFirebaseManager: ObservableObject {
    static let shared = RealFirebaseManager()
    
    private let firestore = Firestore.firestore()
    private let cloudinary = CloudinaryManager.shared
    
    @Published var memories: [Memory] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var uploadProgress: Double = 0.0
    @Published var isSignedIn = true // Always signed in, no auth needed
    @Published var userName = "You"
    
    // Couple identifier - both phones will use the same collection
    private let coupleId = "sarah_john_love_2024" // Change this to your names
    private var listener: ListenerRegistration?
    
    init() {
        // Skip authentication, start listening immediately
        startListeningToMemories()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Real-time Memory Sync
    
    private func startListeningToMemories() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Listen to the shared couple collection in real-time
        listener = firestore.collection("couples").document(coupleId).collection("memories")
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
                        var memory = try document.data(as: Memory.self)
                        memory.id = document.documentID
                        return memory
                    } catch {
                        print("❌ Failed to decode memory: \(error)")
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    self?.memories = fetchedMemories
                    print("✅ Real-time update: \(fetchedMemories.count) memories")
                }
            }
    }
    
    // MARK: - Add Memory with Real-time Sync
    
    func addMemory(_ memory: Memory, images: [UIImage]) async {
        await MainActor.run {
            isLoading = true
            uploadProgress = 0.0
        }
        
        do {
            var memoryToSave = memory
            memoryToSave.createdBy = userName
            
            // Upload multiple images to Cloudinary
            if !images.isEmpty {
                var uploadedUrls: [String] = []
                let totalImages = images.count
                
                for (index, image) in images.enumerated() {
                    await MainActor.run {
                        uploadProgress = Double(index) / Double(totalImages) * 0.8
                    }
                    
                    print("📤 Uploading image \(index + 1)/\(totalImages) to Cloudinary...")
                    let imageUrl = try await cloudinary.uploadImage(image, memoryId: "\(UUID().uuidString)_\(index)")
                    uploadedUrls.append(imageUrl)
                    print("✅ Image \(index + 1) uploaded: \(imageUrl)")
                }
                
                memoryToSave.imageUrls = uploadedUrls
                memoryToSave.thumbnailImageIndex = max(0, min(memoryToSave.thumbnailImageIndex, uploadedUrls.count - 1))
            }
            
            await MainActor.run {
                uploadProgress = 0.9
            }
            
            // Save memory to Firebase Firestore (no auth required)
            print("💾 Saving memory to Firebase...")
            let docRef = try firestore.collection("couples").document(coupleId).collection("memories").addDocument(from: memoryToSave)
            print("✅ Memory saved to Firebase with ID: \(docRef.documentID)")
            
            await MainActor.run {
                uploadProgress = 1.0
                isLoading = false
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
            
            HapticFeedback.shared.error()
        }
    }
    
    // Legacy single image support
    func addMemory(_ memory: Memory, image: UIImage?) async {
        let images = image != nil ? [image!] : []
        await addMemory(memory, images: images)
    }
    
    // MARK: - Delete Memory
    
    func deleteMemory(_ memory: Memory) async {
        guard let memoryId = memory.id else { return }
        
        do {
            // Delete images from Cloudinary
            if !memory.imageUrls.isEmpty {
                for imageUrl in memory.imageUrls {
                    try await cloudinary.deleteImage(from: imageUrl)
                }
                print("🗑️ Images deleted from Cloudinary")
            }
            
            // Delete from Firebase Firestore (no auth required)
            try await firestore.collection("couples").document(coupleId).collection("memories").document(memoryId).delete()
            print("✅ Memory deleted from Firebase")
            
            HapticFeedback.shared.success()
            
        } catch {
            print("❌ Failed to delete memory: \(error)")
            await MainActor.run {
                errorMessage = "Failed to delete memory: \(error.localizedDescription)"
            }
            
            HapticFeedback.shared.error()
        }
    }
    
    // MARK: - Utility Functions
    
    func clearError() {
        errorMessage = ""
    }
    
    func fetchMemories() {
        // For compatibility - restart the real-time listener
        refreshMemories()
    }
    
    func refreshMemories() {
        // Restart the real-time listener
        listener?.remove()
        startListeningToMemories()
    }
    
    // MARK: - Image URL Optimization
    
    func optimizedImageUrl(_ url: String, for size: MemoryImageSize = .medium) -> String {
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
    
    // MARK: - Connection Status
    
    @Published var isConnected = true
    
    // Simple connection check
    func checkConnection() {
        firestore.collection("couples").document(coupleId).getDocument { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isConnected = error == nil
            }
        }
    }
}
