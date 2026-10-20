//
//  MainTabView.swift
//  SocceryTV
//
//  Main tab bar with Home (WebView), Leagues, and Settings.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home - Main WebView
            NavigationStack {
                WebViewScreen(url: URL(string: "https://soccerytv.com/")!)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: "#22c55e"))
                                    .frame(width: 8, height: 8)
                                Text("Soccery TV")
                                    .font(.system(size: 17, weight: .bold))
                            }
                        }
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            // Leagues
            NavigationStack {
                LeaguesView()
            }
            .tabItem {
                Label("Leagues", systemImage: "trophy.fill")
            }
            .tag(1)

            // Download / APK page
            NavigationStack {
                WebViewScreen(url: URL(string: "https://soccerytv.com/app-features/")!)
                    .navigationTitle("Features")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Features", systemImage: "star.fill")
            }
            .tag(2)

            // Settings
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(Color(hex: "#22c55e"))
    }
}

#Preview {
    MainTabView()
}
