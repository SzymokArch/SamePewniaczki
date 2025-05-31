import SwiftUI

struct BlackjackGameView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @AppStorage("selectedPlayerNickname") private var selectedPlayerNickname: String = ""
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.nickname, ascending: true)],
        animation: .default
    ) private var players: FetchedResults<Player>

    var selectedPlayer: Player? {
        players.first(where: { $0.nickname == selectedPlayerNickname })
    }
    
    @Binding var darkModeEnabled: Bool
    @StateObject private var game = BlackjackGame()

    @State private var bet: Double = 10
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🃏 Blackjack").font(.title)

            Slider(value: $bet, in: 10...100, step: 10)
            Text("Zakład: \(Int(bet))")

            VStack {
                Text("🧑‍💼 Krupier")
                Text("Suma: \(game.handValue(game.dealerHand))")
                HStack {
//                    Text("🧑‍💼 Krupier")
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
//                    Text("Suma: \(game.handValue(game.dealerHand))")
                }
                Spacer()
                Text("🧑 Gracz")
                Text("Suma: \(game.handValue(game.playerHand))")
                HStack {
//                    Text("🧑 Gracz")
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
//                    Text("Suma: \(game.handValue(game.playerHand))")
                }
            }

            if !game.message.isEmpty {
                Text(game.message).font(.headline).padding()
            }
            
            Text("Saldo: \(selectedPlayer?.balance ?? 0) 💰")
                .font(.headline)

            Button("Rozpocznij grę") {
                let started = game.startGame(withBet: Int32(bet))
                if !started {
                    showAlert = true
                }
            }
            .disabled(Int(bet) > (selectedPlayer?.balance ?? 0))
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
        .onAppear {
            game.configure(with: selectedPlayer!)
            saveRecord()
        }
    }
    
    func saveRecord() {
        game.onGameEnd = { result in
            let newRecord = GameRecord(context: viewContext)
            newRecord.date = Date()
            newRecord.type = "Blackjack"
            newRecord.bet = Int32(result)
            newRecord.player = selectedPlayer
            
            saveContext(viewContext)
        }
    }
}

#Preview {
    BlackjackGameView(darkModeEnabled: .constant(false)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
