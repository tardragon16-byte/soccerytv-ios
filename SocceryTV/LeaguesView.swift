//
//  LeaguesView.swift
//  SocceryTV
//
//  Quick-access league pages with direct WebView navigation.
//

import SwiftUI

struct League: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let emoji: String
    let urlPath: String
}

struct LeaguesView: View {
    let leagues: [League] = [
        League(name: "Premier League", icon: "sportscourt", emoji: "🏴󠁧󠁢󠁥󠁮󠁧󠁿", urlPath: "/"),
        League(name: "Champions League", icon: "trophy", emoji: "🏆", urlPath: "/"),
        League(name: "La Liga", icon: "sportscourt", emoji: "🇪🇸", urlPath: "/"),
        League(name: "Serie A", icon: "sportscourt", emoji: "🇮🇹", urlPath: "/"),
        League(name: "Bundesliga", icon: "sportscourt", emoji: "🇩🇪", urlPath: "/"),
        League(name: "Ligue 1", icon: "sportscourt", emoji: "🇫🇷", urlPath: "/"),
        League(name: "Europa League", icon: "trophy", emoji: "🌍", urlPath: "/"),
        League(name: "FIFA World Cup", icon: "globe", emoji: "🌐", urlPath: "/"),
        League(name: "UEFA EURO", icon: "flag", emoji: "🇪🇺", urlPath: "/"),
        League(name: "Copa América", icon: "trophy", emoji: "🌎", urlPath: "/"),
        League(name: "Saudi Pro League", icon: "sportscourt", emoji: "🇸🇦", urlPath: "/"),
        League(name: "Africa Cup of Nations", icon: "trophy", emoji: "🌍", urlPath: "/"),
        League(name: "Asian Cup", icon: "trophy", emoji: "🌏", urlPath: "/"),
        League(name: "MLS", icon: "sportscourt", emoji: "🇺🇸", urlPath: "/"),
    ]

    @State private var searchText = ""
    @State private var selectedLeague: League?

    var filteredLeagues: [League] {
        if searchText.isEmpty { return leagues }
        return leagues.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            // Featured banner
            Section {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#22c55e").opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "play.tv.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#22c55e"))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Live Matches")
                            .font(.system(size: 16, weight: .bold))
                        Text("Watch live football from all major leagues")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedLeague = League(name: "Live", icon: "play", emoji: "⚽", urlPath: "/")
                }
            }

            // League list
            Section("All Leagues") {
                ForEach(filteredLeagues) { league in
                    Button {
                        selectedLeague = league
                    } label: {
                        HStack(spacing: 14) {
                            Text(league.emoji)
                                .font(.system(size: 28))
                                .frame(width: 40)

                            Text(league.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search leagues...")
        .navigationTitle("Leagues")
        .navigationDestination(item: $selectedLeague) { league in
            WebViewScreen(url: URL(string: "https://soccerytv.com\(league.urlPath)")!)
                .navigationTitle(league.name)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Make League Hashable for navigationDestination
extension League: Hashable {
    static func == (lhs: League, rhs: League) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    NavigationStack {
        LeaguesView()
    }
}
