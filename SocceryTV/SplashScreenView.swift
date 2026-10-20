//
//  SplashScreenView.swift
//  SocceryTV
//
//  Animated splash screen with Soccery TV branding.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#0f172a"),
                    Color(hex: "#1a2332")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative circles
            Circle()
                .fill(Color(hex: "#22c55e").opacity(0.08))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
                .blur(radius: 60)

            Circle()
                .fill(Color(hex: "#22c55e").opacity(0.06))
                .frame(width: 250, height: 250)
                .offset(x: 120, y: 250)
                .blur(radius: 50)

            VStack(spacing: 20) {
                // Logo area
                ZStack {
                    // Pulse ring
                    Circle()
                        .stroke(Color(hex: "#22c55e").opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                        .opacity(Double(2.0 - pulseScale))

                    // Main circle with icon
                    Circle()
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
                        .frame(width: 90, height: 90)
                        .shadow(color: Color(hex: "#22c55e").opacity(0.4), radius: 20)

                    // Soccer ball icon
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 6) {
                    Text("Soccery TV")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Live Soccer TV HD")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "#22c55e"))

                    Text("Live Football · Scores · Highlights")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                        .padding(.top, 4)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                textOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                pulseScale = 2.0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
