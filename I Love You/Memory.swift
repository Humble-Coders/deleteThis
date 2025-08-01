//
//  Memory.swift
//  OurMemories
//
//  Enhanced data model for Firebase Firestore + Cloudinary
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Memory: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var myStory: String? // His side of the story (blue)
    var herStory: String? // Her side of the story (pink)
    var date: Date
    var imageName: String? // For SF Symbols fallback
    var imageUrls: [String] // Cloudinary URLs
    var thumbnailImageIndex: Int // Index of image to show as thumbnail
    var createdAt: Date
    var createdBy: String // Track who created the memory
    
    init(title: String, description: String = "", myStory: String? = nil, herStory: String? = nil, date: Date, imageName: String? = nil, imageUrls: [String] = [], thumbnailImageIndex: Int = 0, createdBy: String = "unknown") {
        self.title = title
        self.description = description
        self.myStory = myStory
        self.herStory = herStory
        self.date = date
        self.imageName = imageName
        self.imageUrls = imageUrls
        self.thumbnailImageIndex = thumbnailImageIndex
        self.createdAt = Date()
        self.createdBy = createdBy
    }
    
    // Computed property for display text
    var displayDescription: String {
        if let myStory = myStory, let herStory = herStory {
            return "\(myStory) | \(herStory)"
        } else if let myStory = myStory {
            return myStory
        } else if let herStory = herStory {
            return herStory
        } else {
            return description
        }
    }
    
    // Check if has two-sided story
    var hasTwoSidedStory: Bool {
        return myStory != nil || herStory != nil
    }
    
    // Legacy support for single image
    var imageUrl: String? {
        get {
            return imageUrls.first
        }
        set {
            if let newValue = newValue {
                if imageUrls.isEmpty {
                    imageUrls = [newValue]
                } else {
                    imageUrls[0] = newValue
                }
            }
        }
    }
    
    // Get thumbnail image URL
    var thumbnailImageUrl: String? {
        guard !imageUrls.isEmpty,
              thumbnailImageIndex < imageUrls.count else {
            return imageUrls.first
        }
        return imageUrls[thumbnailImageIndex]
    }
    
    // Check if memory has multiple images
    var hasMultipleImages: Bool {
        return imageUrls.count > 1
    }
    
    // For preview/testing
    static let sampleMemories = [
        Memory(
            title: "First Date ❤️",
            description: "Our magical first coffee date at that cute little café. I was so nervous but you made everything feel perfect.",
            date: Date().addingTimeInterval(-86400 * 90),
            imageName: "heart.fill",
            createdBy: "sample"
        ),
        Memory(
            title: "First Kiss 💋",
            description: "Under the stars in the park. Time stopped and the whole world disappeared. Just you and me.",
            date: Date().addingTimeInterval(-86400 * 60),
            imageName: "star.fill",
            createdBy: "sample"
        ),
        Memory(
            title: "First Month Together 🌟",
            description: "Celebrating our first month of pure happiness. Already can't imagine life without you.",
            date: Date().addingTimeInterval(-86400 * 30),
            imageName: "sparkles",
            createdBy: "sample"
        )
    ]
}
