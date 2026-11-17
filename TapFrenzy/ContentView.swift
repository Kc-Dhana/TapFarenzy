
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

    // Challenge 1: Combo variables
    @State private var multiplier = 1
    @State private var lastTap = Date.distantPast

    // Challenge 4: Button shrinking
    @State private var buttonSize: CGFloat = 200

    // Save high score permanently
    @AppStorage("highScore") private var highScore = 0
    @AppStorage("gamesPlayed") private var gamesPlayed = 0

    // Timer runs every second
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
                        .foregroundColor(.cyan)
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

                    Button {

                        // First tap starts the game
                        if phase == .idle {
                            phase = .playing
                        }

                        // Challenge 1: Combo system
                        let currentTime = Date()

                        if currentTime.timeIntervalSince(lastTap) <= 0.3 {
                            multiplier = min(multiplier + 1, 3)
                        } else {
                            multiplier = 1
                        }

                        lastTap = currentTime

                        // Add score using combo multiplier
                        score += multiplier

                        // Challenge 4: Shrink button after each tap
                        buttonSize = max(120, buttonSize - 8)

                        // Vibration feedback
                        UIImpactFeedbackGenerator(style: .light)
                            .impactOccurred()

                    } label: {

                        ZStack {

                            // Outer circle
                            Circle()
                                .stroke(
                                    Color.cyan.opacity(0.3),
                                    lineWidth: 12
                                )

                            // Main circle
                            Circle()
                                .stroke(Color.cyan, lineWidth: 4)

                            // Bike icon
                            Image(systemName: "bicycle")
                                .font(.system(size: buttonSize * 0.30))
                                .foregroundColor(.cyan)

                            // Button text
                            VStack(spacing: 5) {

                                Text("TAP!")
                                    .font(.system(
                                        size: 28,
                                        weight: .black
                                    ))
                                    .foregroundColor(.white)

                                Text("TO RACE")
                                    .font(.caption)
                                    .tracking(2)
                                    .foregroundColor(.cyan)

                                // Show combo multiplier
                                if multiplier > 1 {
                                    Text("x\(multiplier) COMBO!")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        .frame(
                            width: buttonSize,
                            height: buttonSize
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(), value: buttonSize)

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

                            phase = .idle
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 35)
                        .padding(.vertical, 12)
                        .background(Color.cyan)
                        .cornerRadius(25)
                    }
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

            // Countdown only while playing
            if phase == .playing && timeRemaining > 0 {

                timeRemaining -= 1

                // End game when timer reaches zero
                if timeRemaining == 0 {

                    phase = .over
                    gamesPlayed += 1

                    // Save new high score
                    if score > highScore {
                        highScore = score
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
