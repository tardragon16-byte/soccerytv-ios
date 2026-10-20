//
//  SettingsView.swift
//  SocceryTV
//
//  App settings: appearance, cache, about, links.
//

import SwiftUI
import WebKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showClearCacheAlert = false
    @State private var cacheCleared = false

    var body: some View {
        List {
            // App info header
            Section {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#22c55e"),
                                        Color(hex: "#16a34a")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)

                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Soccery TV")
                            .font(.system(size: 20, weight: .black))
                        Text("Live Soccer TV HD")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "#22c55e"))
                        Text("Version 5.4.2 (iOS)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }

            // Appearance
            Section("Appearance") {
                Picker("Theme", selection: $appState.selectedSchemeRaw) {
                    Label("System", systemImage: "circle.lefthalf.filled")
                        .tag("system")
                    Label("Light", systemImage: "sun.max.fill")
                        .tag("light")
                    Label("Dark", systemImage: "moon.fill")
                        .tag("dark")
                }
                .pickerStyle(.menu)
            }

            // Data
            Section("Data") {
                Button {
                    showClearCacheAlert = true
                } label: {
                    HStack {
                        Label("Clear Cache", systemImage: "trash")
                        Spacer()
                        if cacheCleared {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#22c55e"))
                        }
                    }
                }
                .alert("Clear Cache", isPresented: $showClearCacheAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Clear", role: .destructive) {
                        clearWebCache()
                    }
                } message: {
                    Text("This will clear all cached web data. The app will reload content from the internet.")
                }
            }

            // Links
            Section("Links") {
                Link(destination: URL(string: "https://soccerytv.com/")!) {
                    Label("Official Website", systemImage: "globe")
                }

                Link(destination: URL(string: "https://soccerytv.com/faqs/")!) {
                    Label("FAQ", systemImage: "questionmark.circle")
                }

                Link(destination: URL(string: "https://soccerytv.com/contact/")!) {
                    Label("Contact Us", systemImage: "envelope")
                }

                Link(destination: URL(string: "https://soccerytv.com/privacy/")!) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }

                Link(destination: URL(string: "https://soccerytv.com/terms/")!) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
            }

            // Social
            Section("Follow Us") {
                Link(destination: URL(string: "https://www.facebook.com/soccerytv/")!) {
                    Label("Facebook", systemImage: "globe")
                }
                Link(destination: URL(string: "https://x.com/soccery_tv")!) {
                    Label("X (Twitter)", systemImage: "bubble.left")
                }
                Link(destination: URL(string: "https://www.instagram.com/soccerytv/")!) {
                    Label("Instagram", systemImage: "camera")
                }
                Link(destination: URL(string: "https://www.reddit.com/user/soccerytv")!) {
                    Label("Reddit", systemImage: "text.bubble")
                }
            }

            // About
            Section {
                VStack(spacing: 6) {
                    Text("Soccery TV for iOS")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Live football scores, highlights and match coverage.\nNot affiliated with any sports broadcaster or league.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Text("© 2026 Soccery TV · All rights reserved")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Settings")
    }

    private func clearWebCache() {
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let dateFrom = Date(timeIntervalSince1970: 0)

        dataStore.removeData(ofTypes: dataTypes, modifiedSince: dateFrom) {
            DispatchQueue.main.async {
                cacheCleared = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    cacheCleared = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
