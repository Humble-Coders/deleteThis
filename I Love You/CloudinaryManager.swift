//
//  CloudinaryManager.swift
//  OurMemories
//
//  Enhanced Cloudinary integration with optimization and error handling
//

import Foundation
import UIKit

class CloudinaryManager {
    static let shared = CloudinaryManager()
    
    // 🔥 REPLACE THESE WITH YOUR CLOUDINARY VALUES
    private let cloudName = "dx1fvrp3m"  // e.g., "dp1a2b3c4"
    private let uploadPreset = "our_memories_preset"  // The preset you created
    
    private init() {}
    
    func uploadImage(_ image: UIImage, memoryId: String) async throws -> String {
        // Optimize image before upload
        guard let optimizedImage = optimizeImage(image),
              let imageData = optimizedImage.jpegData(compressionQuality: 0.85) else {
            throw CloudinaryError.imageProcessingFailed
        }
        
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60.0 // 60 seconds timeout
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add upload preset
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        body.appendString("\(uploadPreset)\r\n")
        
        // Add public ID for easy identification
        let publicId = "memory_\(memoryId)_\(Int(Date().timeIntervalSince1970))"
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"public_id\"\r\n\r\n")
        body.appendString("\(publicId)\r\n")
        
        // Add folder for organization
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"folder\"\r\n\r\n")
        body.appendString("our_memories\r\n")
        
        // Add tags for better organization
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"tags\"\r\n\r\n")
        body.appendString("love_memory,anniversary,couple\r\n")
        
        // Add context (metadata)
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"context\"\r\n\r\n")
        body.appendString("memory_id=\(memoryId)|upload_date=\(ISO8601DateFormatter().string(from: Date()))\r\n")
        
        // Add the image file
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"memory.jpg\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CloudinaryError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                // Try to get error message from response
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorData["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw CloudinaryError.uploadFailed(message)
                }
                throw CloudinaryError.uploadFailed("HTTP \(httpResponse.statusCode)")
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let secureUrl = json["secure_url"] as? String else {
                throw CloudinaryError.invalidResponse
            }
            
            print("✅ Image uploaded successfully: \(secureUrl)")
            return secureUrl
            
        } catch {
            print("❌ Upload failed: \(error)")
            throw error
        }
    }
    
    func deleteImage(from url: String) async throws {
        // Extract public ID from Cloudinary URL
        guard let publicId = extractPublicId(from: url) else {
            throw CloudinaryError.invalidUrl
        }
        
        print("🗑️ Would delete image with public ID: \(publicId)")
        // Note: Deletion requires signed requests with API secret
        // For a love app, you might not need deletion, or handle it server-side
        // For now, we'll just log it and handle gracefully
    }
    
    // Generate optimized URL with transformations
    func optimizedUrl(from baseUrl: String, width: Int = 400, height: Int = 300, quality: String = "auto") -> String {
        guard let publicId = extractPublicId(from: baseUrl) else {
            return baseUrl
        }
        
        // Create optimized URL with transformations
        let transformations = "c_fill,w_\(width),h_\(height),q_\(quality),f_auto,dpr_auto"
        return "https://res.cloudinary.com/\(cloudName)/image/upload/\(transformations)/\(publicId)"
    }
    
    // Generate thumbnail URL
    func thumbnailUrl(from baseUrl: String) -> String {
        return optimizedUrl(from: baseUrl, width: 150, height: 150, quality: "auto:low")
    }
    
    // MARK: - Private Helpers
    
    private func optimizeImage(_ image: UIImage) -> UIImage? {
        // Resize image if too large (max 1200px width)
        let maxWidth: CGFloat = 1200
        let maxHeight: CGFloat = 1200
        
        if image.size.width <= maxWidth && image.size.height <= maxHeight {
            return image
        }
        
        let aspectRatio = image.size.width / image.size.height
        var newSize: CGSize
        
        if aspectRatio > 1 {
            // Landscape
            newSize = CGSize(width: maxWidth, height: maxWidth / aspectRatio)
        } else {
            // Portrait
            newSize = CGSize(width: maxHeight * aspectRatio, height: maxHeight)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    private func extractPublicId(from url: String) -> String? {
        // Extract public ID from Cloudinary URL
        // URL format: https://res.cloudinary.com/cloud/image/upload/v123456/folder/public_id.jpg
        let components = url.components(separatedBy: "/")
        
        guard let uploadIndex = components.firstIndex(of: "upload") else {
            return nil
        }
        
        // Get everything after /upload/ (skip version if present)
        let remainingComponents = Array(components.dropFirst(uploadIndex + 1))
        
        // Skip version number if present (starts with 'v')
        let publicIdComponents = remainingComponents.first?.hasPrefix("v") == true ?
            Array(remainingComponents.dropFirst()) : remainingComponents
        
        // Join components and remove file extension
        let publicIdWithExtension = publicIdComponents.joined(separator: "/")
        
        // Remove file extension
        if let lastDotIndex = publicIdWithExtension.lastIndex(of: ".") {
            return String(publicIdWithExtension[..<lastDotIndex])
        }
        
        return publicIdWithExtension
    }
}

// MARK: - Error Handling
enum CloudinaryError: LocalizedError {
    case imageProcessingFailed
    case invalidResponse
    case uploadFailed(String)
    case invalidUrl
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process image for upload"
        case .invalidResponse:
            return "Invalid response from Cloudinary"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .invalidUrl:
            return "Invalid Cloudinary URL"
        }
    }
}

// MARK: - Data Extension
extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
