//
//  SocceryTVApp.swift
//  SocceryTV
//
//  Created for Soccery TV - iOS WebView Wrapper
//  Live Soccer TV HD
//

import SwiftUI

@main
struct SocceryTVApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @AppStorage("selectedColorScheme") var selectedSchemeRaw: String = "system"

    var colorScheme: ColorScheme? {
        switch selectedSchemeRaw {
        case "light": return .light
        case "dark": return .dark
        default: return nil // system
        }
    }
}
