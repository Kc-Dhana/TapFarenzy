
import SwiftUI
import Combine
import UIKit

// MARK: - Game Phases

enum GamePhase {
    case idle
    case playing
    case over
}

struct ContentView: View {

    // MARK: - Game Variables

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var phase: GamePhase = .idle

    // Combo variables
    @State private var multiplier = 1
    @State private var lastTap = Date.distantPast

    // Button shrinking
    @State private var buttonSize: CGFloat = 200

    // MARK: - Animation Variables

    @State private var buttonBounce = false
    @State private var buttonGlow = false
    @State private var comboPulse = false
    @State private var scorePop = false

    @State private var floatingScore = 0
    @State private var showFloatingScore = false
    @State private var scorePopupID = UUID()

    // Save high score permanently
    @AppStorage("highScore") private var highScore = 0
    @AppStorage("gamesPlayed") private var gamesPlayed = 0

    // Timer
    let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {

        ZStack {

            // MARK: - Background

            Color(red: 0.04, green: 0.06, blue: 0.15)
                .ignoresSafeArea()

            VStack(spacing: 22) {

                // MARK: - Game Title

                VStack(spacing: 5) {

                    Text("TAP FRENZY")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.white)

                    Text("BIKE CHALLENGE")
                        .font(.headline)
                        .tracking(4)
                        .foregroundColor(.cyan)
                }
                .padding(.top, 20)

                // MARK: - Score and High Score

                HStack(spacing: 15) {

                    VStack(spacing: 8) {

                        Text("YOUR SCORE")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("\(score)")
                            .font(.system(size: 38, weight: .heavy))
                            .foregroundColor(.cyan)
                            .contentTransition(.numericText())
                            .scaleEffect(scorePop ? 1.2 : 1.0)
                            .animation(
                                .spring(response: 0.25, dampingFraction: 0.4),
                                value: score
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.18))
                    .cornerRadius(18)

                    VStack(spacing: 8) {

                        Text("BEST SCORE")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("\(highScore)")
                            .font(.system(size: 38, weight: .heavy))
                            .foregroundColor(.purple)
                            .contentTransition(.numericText())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.18))
                    .cornerRadius(18)
                }

                // MARK: - Countdown Timer

                VStack(spacing: 8) {

                    Text("TIME LEFT")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.gray)

                    Text("\(timeRemaining) SEC")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(timeRemaining <= 3 ? .red : .cyan)
                        .contentTransition(.numericText())
                        .scaleEffect(timeRemaining <= 3 ? 1.1 : 1.0)
                }

                // MARK: - Progress Bar

                HStack(spacing: 10) {

                    ProgressView(
                        value: Double(10 - timeRemaining),
                        total: 10
                    )
                    .tint(.cyan)

                    Image(systemName: "bicycle")
                        .font(.title2)
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 10)

                Spacer()

                // MARK: - Game Button

                if phase != .over {

                    ZStack {

                        Button {

                            // First tap starts the game
                            if phase == .idle {
                                phase = .playing
                            }

                            // Combo system
                            let currentTime = Date()

                            if currentTime.timeIntervalSince(lastTap) <= 0.3 {
                                multiplier = min(multiplier + 1, 3)
                            } else {
                                multiplier = 1
                            }

                            lastTap = currentTime

                            // Add score using combo multiplier
                            score += multiplier

                            // Challenge 4: Shrink button
                            buttonSize = max(120, buttonSize - 8)

                            // Floating score popup
                            showScorePopup(multiplier)

                            // Button bounce
                            withAnimation(
                                .spring(response: 0.18, dampingFraction: 0.35)
                            ) {
                                buttonBounce = true
                                buttonGlow = true
                            }

                            // Score pulse
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                                scorePop = true
                            }

                            // Combo animation
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                                comboPulse = true
                            }

                            // Vibration
                            UIImpactFeedbackGenerator(style: .light)
                                .impactOccurred()

                            // Button release
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {

                                withAnimation(
                                    .spring(response: 0.35, dampingFraction: 0.45)
                                ) {
                                    buttonBounce = false
                                    buttonGlow = false
                                    scorePop = false
                                    comboPulse = false
                                }
                            }

                        } label: {

                            ZStack {

                                // Outer glowing circle
                                Circle()
                                    .stroke(
                                        Color.cyan.opacity(0.25),
                                        lineWidth: 12
                                    )
                                    .shadow(
                                        color: .cyan.opacity(buttonGlow ? 0.9 : 0.2),
                                        radius: buttonGlow ? 30 : 10
                                    )

                                // Main circle
                                Circle()
                                    .stroke(
                                        Color.cyan,
                                        lineWidth: 4
                                    )
                                    .shadow(
                                        color: .cyan.opacity(0.8),
                                        radius: buttonGlow ? 20 : 5
                                    )

                                // Inner background
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color.cyan.opacity(0.2),
                                                Color.blue.opacity(0.08),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 5,
                                            endRadius: buttonSize / 2
                                        )
                                    )

                                // Hand icon
                                Image(systemName: "hand.tap.fill")
                                    .font(
                                        .system(size: buttonSize * 0.20)
                                    )
                                    .foregroundColor(.cyan)
                                    .offset(y: -5)

                                // Button text
                                VStack(spacing: 0) {

                                    Text("TAP")
                                        .font(
                                            .system(
                                                size: 28,
                                                weight: .black
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .offset(y: -30)

                                    Text("TAP!")
                                        .font(.caption)
                                        .tracking(2)
                                        .foregroundColor(.cyan)
                                        .offset(y: 20)

                                    if multiplier > 1 {

                                        Text("x\(multiplier) COMBO!")
                                            .font(.headline)
                                            .bold()
                                            .foregroundColor(.yellow)
                                            .scaleEffect(
                                                comboPulse ? 1.35 : 1.0
                                            )
                                            .shadow(
                                                color: .yellow.opacity(0.9),
                                                radius: comboPulse ? 15 : 4
                                            )
                                    }
                                }
                            }
                            .frame(
                                width: buttonSize,
                                height: buttonSize
                            )
                            .scaleEffect(buttonBounce ? 0.88 : 1.0)
                        }
                        .buttonStyle(.plain)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.5),
                            value: buttonSize
                        )

                        // MARK: - Floating Score

                        if showFloatingScore {

                            Text("+\(floatingScore)")
                                .font(
                                    .system(size: 32, weight: .black)
                                )
                                .foregroundColor(.yellow)
                                .shadow(
                                    color: .orange.opacity(0.9),
                                    radius: 12
                                )
                                .offset(
                                    x: 105,
                                    y: -105
                                )
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .top)
                                            .combined(with: .opacity)
                                            .combined(with: .scale(scale: 0.5)),
                                        removal: .move(edge: .top)
                                            .combined(with: .opacity)
                                    )
                                )
                                .id(scorePopupID)
                        }
                    }

                } else {

                    // MARK: - Game Over Screen

                    VStack(spacing: 15) {

                        Text("RACE FINISHED!")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.cyan)

                        Text("FINAL SCORE")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("\(score)")
                            .font(.system(size: 55, weight: .heavy))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())

                        Text("Best: \(highScore)")
                            .font(.headline)
                            .foregroundColor(.purple)

                        // Restart game
                        Button("PLAY AGAIN") {

                            score = 0
                            timeRemaining = 10
                            multiplier = 1
                            lastTap = .distantPast
                            buttonSize = 200

                            buttonBounce = false
                            buttonGlow = false
                            comboPulse = false
                            scorePop = false
                            showFloatingScore = false

                            phase = .idle
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 35)
                        .padding(.vertical, 12)
                        .background(Color.cyan)
                        .cornerRadius(25)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // MARK: - Games Played

                Text("GAMES PLAYED: \(gamesPlayed)")
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 22)
        }

        .preferredColorScheme(.dark)

        // MARK: - Timer Logic

        .onReceive(timer) { _ in

            if phase == .playing && timeRemaining > 0 {

                timeRemaining -= 1

                if timeRemaining == 0 {

                    phase = .over
                    gamesPlayed += 1

                    // Save high score
                    if score > highScore {
                        highScore = score
                    }
                }
            }
        }
    }

    // MARK: - Floating Score Animation

    private func showScorePopup(_ points: Int) {

        floatingScore = points
        scorePopupID = UUID()

        withAnimation(
            .spring(response: 0.35, dampingFraction: 0.55)
        ) {
            showFloatingScore = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {

            withAnimation(.easeOut(duration: 0.3)) {
                showFloatingScore = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
