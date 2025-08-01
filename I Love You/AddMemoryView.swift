//
//  AddMemoryView.swift
//  OurMemories
//
//  Complete working version with two-sided stories and clean UI
//

import SwiftUI
import PhotosUI

struct AddMemoryView: View {
    @EnvironmentObject var firebaseManager: RealFirebaseManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var myStory = ""
    @State private var herStory = ""
    @State private var selectedDate = Date()
    @State private var selectedIcon = "heart.fill"
    @State private var selectedImages: [UIImage] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var thumbnailIndex = 0
    @State private var isUploading = false
    @State private var showingImageViewer = false
    @State private var viewerStartIndex = 0
    @State private var showingStoryInput = false
    
    let iconOptions = ["heart.fill", "star.fill", "sparkles", "sun.max.fill", "moon.stars.fill", "camera.fill", "gift.fill", "balloon.fill", "hands.sparkles.fill", "crown.fill"]
    
    var body: some View {
        NavigationView {
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
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Add New Memory")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Capture this beautiful moment forever")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Multiple images section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Add Photos")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if !selectedImages.isEmpty {
                                    Text("\(selectedImages.count) photo\(selectedImages.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.pink.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if selectedImages.isEmpty {
                                // Photo picker button
                                PhotosPicker(
                                    selection: $selectedPhotoItems,
                                    maxSelectionCount: 10,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.gray.opacity(0.1))
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.pink, Color.purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                style: StrokeStyle(lineWidth: 2, dash: [10])
                                            )
                                            .frame(height: 200)
                                        
                                        VStack(spacing: 12) {
                                            Image(systemName: "photo.badge.plus")
                                                .font(.system(size: 40))
                                                .foregroundColor(.pink)
                                            
                                            Text("Tap to add photos")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            
                                            Text("Select up to 10 photos")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                            } else {
                                // Selected images display
                                VStack(spacing: 12) {
                                    // Main preview image
                                    ZStack {
                                        Image(uiImage: selectedImages[thumbnailIndex])
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 200)
                                            .cornerRadius(20)
                                            .clipped()
                                            .onTapGesture {
                                                viewerStartIndex = thumbnailIndex
                                                showingImageViewer = true
                                            }
                                        
                                        // Thumbnail indicator
                                        VStack {
                                            HStack {
                                                Spacer()
                                                
                                                ZStack {
                                                    Capsule()
                                                        .fill(Color.pink)
                                                        .frame(height: 24)
                                                    
                                                    Text("Thumbnail")
                                                        .font(.caption2)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 8)
                                                }
                                            }
                                            .padding(8)
                                            
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    // Image thumbnails grid (cleaner design)
                                    if selectedImages.count > 1 {
                                        VStack(spacing: 12) {
                                            HStack {
                                                Text("Choose Thumbnail")
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Text("Tap to select")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.horizontal, 20)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 16) {
                                                    ForEach(selectedImages.indices, id: \.self) { index in
                                                        ZStack {
                                                            Image(uiImage: selectedImages[index])
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 80, height: 80)
                                                                .cornerRadius(16)
                                                                .clipped()
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 16)
                                                                        .stroke(
                                                                            thumbnailIndex == index ? Color.pink : Color.gray.opacity(0.3),
                                                                            lineWidth: thumbnailIndex == index ? 3 : 1
                                                                        )
                                                                )
                                                                .scaleEffect(thumbnailIndex == index ? 1.05 : 1.0)
                                                                .shadow(color: thumbnailIndex == index ? .pink.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                                                                .onTapGesture {
                                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                                        thumbnailIndex = index
                                                                    }
                                                                    HapticFeedback.shared.medium()
                                                                }
                                                            
                                                            // Thumbnail indicator
                                                            if thumbnailIndex == index {
                                                                VStack {
                                                                    HStack {
                                                                        Spacer()
                                                                        ZStack {
                                                                            Circle()
                                                                                .fill(Color.pink)
                                                                                .frame(width: 24, height: 24)
                                                                            
                                                                            Image(systemName: "checkmark")
                                                                                .font(.caption)
                                                                                .fontWeight(.bold)
                                                                                .foregroundColor(.white)
                                                                        }
                                                                        .offset(x: 8, y: -8)
                                                                    }
                                                                    Spacer()
                                                                }
                                                            }
                                                            
                                                            // Remove button
                                                            VStack {
                                                                HStack {
                                                                    Button(action: {
                                                                        removeImage(at: index)
                                                                    }) {
                                                                        ZStack {
                                                                            Circle()
                                                                                .fill(Color.red)
                                                                                .frame(width: 24, height: 24)
                                                                            
                                                                            Image(systemName: "xmark")
                                                                                .font(.system(size: 12, weight: .bold))
                                                                                .foregroundColor(.white)
                                                                        }
                                                                    }
                                                                    .offset(x: -8, y: -8)
                                                                    
                                                                    Spacer()
                                                                }
                                                                
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 20)
                                            }
                                        }
                                    }
                                    
                                    // Add more photos button
                                    PhotosPicker(
                                        selection: $selectedPhotoItems,
                                        maxSelectionCount: 10,
                                        matching: .images,
                                        photoLibrary: .shared()
                                    ) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.pink)
                                            
                                            Text("Add More Photos")
                                                .font(.subheadline)
                                                .foregroundColor(.pink)
                                        }
                                        .padding(.vertical, 8)
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .onChange(of: selectedPhotoItems) { newItems in
                            Task {
                                var newImages: [UIImage] = []
                                
                                for item in newItems {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        newImages.append(image)
                                    }
                                }
                                
                                await MainActor.run {
                                    selectedImages = newImages
                                    thumbnailIndex = 0
                                }
                            }
                        }
                        
                        // Enhanced form fields with better spacing
                        VStack(spacing: 24) {
                            // Title input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Memory Title")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Our magical first kiss 💋", text: $title)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                                    .submitLabel(.next)
                            }
                            .padding(.horizontal, 20)
                            
                            // Two-sided story toggle
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Tell Our Story")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingStoryInput.toggle()
                                        HapticFeedback.shared.light()
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: showingStoryInput ? "person.2.fill" : "person.fill")
                                                .font(.caption)
                                            Text(showingStoryInput ? "Two Sides" : "One Story")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(.pink)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.pink.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                                
                                if showingStoryInput {
                                    // Two-sided story input
                                    VStack(spacing: 16) {
                                        // His side (blue)
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Circle()
                                                    .fill(Color.blue)
                                                    .frame(width: 12, height: 12)
                                                Text("His Side")
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            TextField("Tell your side of this beautiful moment...", text: $myStory, axis: .vertical)
                                                .textFieldStyle(.roundedBorder)
                                                .font(.body)
                                                .lineLimit(3...6)
                                        }
                                        
                                        // Her side (pink)
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Circle()
                                                    .fill(Color.pink)
                                                    .frame(width: 12, height: 12)
                                                Text("Her Side")
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.pink)
                                            }
                                            
                                            TextField("Tell her side of this beautiful moment...", text: $herStory, axis: .vertical)
                                                .textFieldStyle(.roundedBorder)
                                                .font(.body)
                                                .lineLimit(3...6)
                                        }
                                    }
                                } else {
                                    // Single story input
                                    TextField("Describe this beautiful moment in detail...", text: $description, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .font(.body)
                                        .lineLimit(3...6)
                                        .submitLabel(.done)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Date picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("When did this happen?")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                DatePicker("Select date", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            
                            // Icon selector (only if no images) - cleaner layout
                            if selectedImages.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Choose a Symbol")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 5), spacing: 20) {
                                        ForEach(iconOptions, id: \.self) { icon in
                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    selectedIcon = icon
                                                }
                                                HapticFeedback.shared.light()
                                            }) {
                                                ZStack {
                                                    Circle()
                                                        .fill(selectedIcon == icon ?
                                                              LinearGradient(colors: [Color.pink, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                                              LinearGradient(colors: [Color.gray.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                        .frame(width: 56, height: 56)
                                                        .shadow(color: selectedIcon == icon ? .pink.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                                                    
                                                    Image(systemName: icon)
                                                        .font(.title2)
                                                        .foregroundColor(selectedIcon == icon ? .white : .gray)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .scaleEffect(selectedIcon == icon ? 1.05 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIcon)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Save button with better spacing
                        Button(action: saveMemory) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: canSave ? [Color.pink, Color.purple] : [Color.gray.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 56)
                                    .shadow(color: canSave ? .pink.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                                
                                if isUploading {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        
                                        Text("Saving Memory...")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        if firebaseManager.uploadProgress > 0 {
                                            Text("(\(Int(firebaseManager.uploadProgress * 100))%)")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                } else {
                                    Text("Save Our Memory 💕")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(canSave ? .white : .gray)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .disabled(!canSave || isUploading)
                        .scaleEffect(canSave && !isUploading ? 1.0 : 0.95)
                        .animation(.easeInOut(duration: 0.2), value: canSave)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.pink)
                    .disabled(isUploading)
                }
            }
            .fullScreenCover(isPresented: $showingImageViewer) {
                if !selectedImages.isEmpty {
                    LocalImageViewer(
                        images: selectedImages,
                        startingIndex: viewerStartIndex
                    )
                }
            }
        }
    }
    
    var canSave: Bool {
        !title.isEmpty && (!showingStoryInput ? !description.isEmpty : (!myStory.isEmpty || !herStory.isEmpty)) && !isUploading
    }
    
    func removeImage(at index: Int) {
        withAnimation(.easeInOut) {
            selectedImages.remove(at: index)
            
            // Adjust thumbnail index if needed
            if thumbnailIndex >= selectedImages.count {
                thumbnailIndex = max(0, selectedImages.count - 1)
            }
        }
        HapticFeedback.shared.medium()
    }
    
    func saveMemory() {
        guard canSave else { return }
        
        isUploading = true
        
        let newMemory = Memory(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: showingStoryInput ? "" : description.trimmingCharacters(in: .whitespacesAndNewlines),
            myStory: showingStoryInput && !myStory.isEmpty ? myStory.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            herStory: showingStoryInput && !herStory.isEmpty ? herStory.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            date: selectedDate,
            imageName: selectedImages.isEmpty ? selectedIcon : nil,
            imageUrls: [],
            thumbnailImageIndex: thumbnailIndex,
            createdBy: "You"
        )
        
        Task {
            await firebaseManager.addMemory(newMemory, images: selectedImages)
            
            await MainActor.run {
                isUploading = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Local Image Viewer for Selected Images
struct LocalImageViewer: View {
    let images: [UIImage]
    @State private var currentIndex: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    
    init(images: [UIImage], startingIndex: Int = 0) {
        self.images = images
        self._currentIndex = State(initialValue: startingIndex)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
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
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentIndex) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    scale = 1.0
                    offset = .zero
                }
            }
            
            // Controls
            VStack {
                HStack {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(25)
                    
                    Spacer()
                    
                    if images.count > 1 {
                        Text("\(currentIndex + 1) / \(images.count)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(25)
                    }
                }
                .padding()
                
                Spacer()
                
                if images.count > 1 {
                    HStack(spacing: 12) {
                        ForEach(images.indices, id: \.self) { index in
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
        .statusBarHidden()
    }
}

#Preview {
    AddMemoryView()
        .environmentObject(RealFirebaseManager.shared)
}
