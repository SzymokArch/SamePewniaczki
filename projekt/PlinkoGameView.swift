//
//  ContentView.swift
//  plinko
//
//  Created by macOS on 16/04/2025.
//

import SwiftUI

struct PlinkoGameView: View {
    @AppStorage("selectedPlayerNickname") private var selectedPlayerNickname: String = "Gracz"

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.nickname, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Player>

    var selectedPlayer: Player? {
        players.first(where: { $0.nickname == selectedPlayerNickname })
    }

    @Binding var darkModeEnabled: Bool
    @AppStorage("ballColorHex") private var ballColorHex: String = "#FF0000"

    var ballColor: Color {
        Color(hex: ballColorHex) ?? .red
    }
    
    @StateObject private var game: PlinkoGameLogic = PlinkoGameLogic()
    @State private var spawnTimer: Timer?
    
    var backgroundColor: Color {
        darkModeEnabled ? Color.black : Color.white
    }

    var pinColor: Color {
        darkModeEnabled ? Color(white: 0.7) : Color.gray
    }

    var basketColor: Color {
        darkModeEnabled ? Color.blue.opacity(0.7) : Color.blue
    }
    
    var body: some View {
        VStack {
            if let player = selectedPlayer {
                Text("Stan konta: \(player.balance)")
                    .font(.headline)
            } else {
                Text("Brak wybranego gracza")
                    .foregroundColor(.gray)
            }

            Text("Tap")
                .frame(width: 100, height: 80)
                .background(Color.clear)
                .border(Color.gray, width: 2)
                .contentShape(Rectangle())
                .onTapGesture {
                    game.dropBall(selectedPlayer: selectedPlayer)
                }
                .onLongPressGesture(minimumDuration: 0.2, pressing: { isPressing in
                    if isPressing {
                        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                            game.dropBall(selectedPlayer: selectedPlayer)
                        }
                    } else {
                        spawnTimer?.invalidate()
                        spawnTimer = nil
                    }
                }, perform: {})
            ZStack{
                ForEach(game.pins) { pin in
                    Circle()
                        .fill(pinColor)
                        .frame(width: 8, height: 8)
                        .position(x: pin.x, y: pin.y)
                }
                
                HStack(spacing: 0) {
                    ForEach(Array(game.baskets.enumerated()), id: \.element.id) { index, basket in
                        Text("\(basketValue[index])")
                            .font(.caption2)
                            .frame(maxWidth: .infinity, maxHeight: 30)
                            .border(Color.gray, width: 1)
                    }
                }
                .frame(width: screenWidth)
                .position(x:screenWidth/2 ,y: screenHeight - 60)
                
                ForEach(game.balls) { ball in
                    Circle()
                        .fill(ballColor)
                        .frame(width: 12, height: 12)
                        .position(x: ball.x, y: ball.y)
                }
            }
        }
        .frame(width: screenWidth, height: screenHeight)
        .background(backgroundColor)
        .onAppear{
            game.initGame(selectedPlayer: selectedPlayer)
        }
        .onDisappear {
            saveRecord()
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
    
    func saveRecord() {
        if let player = selectedPlayer {
            let finalBalance = player.balance
            let balanceChange = finalBalance - game.initialBalance

            let record = GameRecord(context: viewContext)
            record.date = Date()
            record.bet = balanceChange
            record.type = "Plinko"
            record.player = player

            saveContext(viewContext)
        }
    }
}

#Preview {
    PlinkoGameView(darkModeEnabled: .constant(false)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
