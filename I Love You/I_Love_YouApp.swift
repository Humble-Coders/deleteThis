//
//  I_Love_YouApp.swift
//
//  Main app entry point with proper Firebase integration
//

import SwiftUI
import FirebaseCore

// App Delegate for Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct I_Love_YouApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebaseManager = RealFirebaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firebaseManager)
                .preferredColorScheme(.light)
        }
    }
}
