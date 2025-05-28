import SwiftUI

struct BlackjackGameView: View {
    @Binding var darkModeEnabled: Bool
    @StateObject private var game = BlackjackGame()

    @State private var bet: Double = 10
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🃏 Blackjack").font(.title)

            Slider(value: $bet, in: 10...100, step: 10)
            Text("Zakład: \(Int(bet))")

            HStack {
                VStack {
                    Text("🧑‍💼 Krupier")
                    ForEach(game.dealerHand) { card in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(radius: 2)
                                .frame(width: 50, height: 70)

                            Text("\(card.display)\(card.suit.rawValue)")
                                .foregroundColor(card.suit.color)
                                .font(.system(size: 20, weight: .bold))
                        }

                    }
                    Text("Suma: \(game.handValue(game.dealerHand))")
                }
                Spacer()
                VStack {
                    Text("🧑 Gracz")
                    ForEach(game.playerHand) { card in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(radius: 2)
                                .frame(width: 50, height: 70)

                            Text("\(card.display)\(card.suit.rawValue)")
                                .foregroundColor(card.suit.color)
                                .font(.system(size: 20, weight: .bold))
                        }

                    }
                    Text("Suma: \(game.handValue(game.playerHand))")
                }
            }

            if !game.message.isEmpty {
                Text(game.message).font(.headline).padding()
            }
            
            Text("Saldo: \(game.balance) 💰")
                .font(.headline)

            Button("Rozpocznij grę") {
                let started = game.startGame(withBet: Int(bet))
                if !started {
                    showAlert = true
                }
            }
            .disabled(Int(bet) > game.balance)
            .alert("Uwaga", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(game.message)
            }

            Spacer()

            Text("Swipe ➡️ = Dobierz kartę | ⬅️ = Stop")
                .font(.footnote).foregroundColor(.gray)
        }
        .padding()
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 && !game.isGameOver {
                        game.playerHits()
                    } else if value.translation.width < -50 && !game.isGameOver {
                        game.playerStands()
                    }
                }
        )

        .onTapGesture(count: 2) {
            bet *= 2
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
}

#Preview {
    BlackjackGameView(darkModeEnabled: .constant(false))
}
