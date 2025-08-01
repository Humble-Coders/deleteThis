//
//  SimpleFirebaseManager.swift
//  OurMemories
//
//  Simplified Firebase manager with better error handling - FIXED VERSION
//

import Foundation
import SwiftUI

// Simple Firebase alternative using just local storage
class SimpleFirebaseManager: ObservableObject {
    static let shared = SimpleFirebaseManager()
    
    @Published var memories: [Memory] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var uploadProgress: Double = 0.0
    
    private let cloudinary = CloudinaryManager.shared
    
    // For now, we'll use UserDefaults + Cloudinary (you can add Firebase later)
    private let userDefaults = UserDefaults.standard
    private let memoriesKey = "SavedMemories"
    
    init() {
        loadMemoriesFromLocal()
    }
    
    // MARK: - Memory Operations
    
    func fetchMemories() {
        loadMemoriesFromLocal()
    }
    
    func addMemory(_ memory: Memory, images: [UIImage]) async {
        await MainActor.run {
            isLoading = true
            uploadProgress = 0.0
        }
        
        do {
            var memoryToSave = memory
            let memoryId = UUID().uuidString
            memoryToSave.id = memoryId
            
            // Upload multiple images to Cloudinary if provided
            if !images.isEmpty {
                var uploadedUrls: [String] = []
                let totalImages = images.count
                
                for (index, image) in images.enumerated() {
                    await MainActor.run {
                        uploadProgress = Double(index) / Double(totalImages) * 0.8
                    }
                    
                    print("📤 Uploading image \(index + 1)/\(totalImages) to Cloudinary...")
                    let imageUrl = try await cloudinary.uploadImage(image, memoryId: "\(memoryId)_\(index)")
                    uploadedUrls.append(imageUrl)
                    print("✅ Image \(index + 1) uploaded: \(imageUrl)")
                }
                
                memoryToSave.imageUrls = uploadedUrls
                memoryToSave.thumbnailImageIndex = 0 // Default to first image
                
                await MainActor.run {
                    uploadProgress = 0.9
                }
            }
            
            // Save to local storage
            await MainActor.run {
                memories.insert(memoryToSave, at: 0) // Add to beginning
                saveMemoriesToLocal()
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
    
    func deleteMemory(_ memory: Memory) async {
        guard let memoryId = memory.id else { return }
        
        do {
            // Delete images from Cloudinary if exist
            if !memory.imageUrls.isEmpty {
                for imageUrl in memory.imageUrls {
                    try await cloudinary.deleteImage(from: imageUrl)
                }
                print("🗑️ Images deleted from Cloudinary")
            }
            
            // Remove from local storage
            await MainActor.run {
                memories.removeAll { $0.id == memoryId }
                saveMemoriesToLocal()
            }
            
            print("✅ Memory deleted locally")
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
    
    // MARK: - Local Storage
    
    private func saveMemoriesToLocal() {
        do {
            let data = try JSONEncoder().encode(memories)
            userDefaults.set(data, forKey: memoriesKey)
            print("💾 Saved \(memories.count) memories locally")
        } catch {
            print("❌ Failed to save memories locally: \(error)")
        }
    }
    
    private func loadMemoriesFromLocal() {
        guard let data = userDefaults.data(forKey: memoriesKey) else {
            print("📭 No local memories found")
            memories = Memory.sampleMemories // Start with sample data
            return
        }
        
        do {
            memories = try JSONDecoder().decode([Memory].self, from: data)
            print("✅ Loaded \(memories.count) memories from local storage")
            
            // Migrate any old format memories
            migrateOldMemories()
            
        } catch {
            print("❌ Failed to load memories: \(error)")
            
            // Try to recover by clearing old data and starting fresh
            print("🔄 Attempting to recover by clearing old data...")
            userDefaults.removeObject(forKey: memoriesKey)
            memories = Memory.sampleMemories // Fallback to sample data
            saveMemoriesToLocal() // Save the sample data in new format
        }
    }
    
    // Migrate memories from old format to new format
    private func migrateOldMemories() {
        var needsUpdate = false
        
        for i in memories.indices {
            var memory = memories[i]
            
            // Ensure createdAt exists
            if memory.createdAt.timeIntervalSince1970 < 1000000000 { // Very old date
                memory.createdAt = memory.date
                needsUpdate = true
            }
            
            // Ensure id exists
            if memory.id == nil || memory.id?.isEmpty == true {
                memory.id = UUID().uuidString
                needsUpdate = true
            }
            
            memories[i] = memory
        }
        
        if needsUpdate {
            print("🔄 Migrated memories to new format")
            saveMemoriesToLocal()
        }
    }
    
    // MARK: - Image URL Optimization (Simple version)
    
    func optimizedImageUrl(_ url: String, for size: MemoryImageSize = .medium) -> String {
        // For now, just return the original URL
        // You can add Cloudinary transformations here later
        return url
    }
}
