//
//  ContentView.swift
//  projekt
//
//  Created by macOS on 10/05/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.nickname, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Player>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GameRecord.date, ascending: false)],
        animation: .default)
    private var gameRecords: FetchedResults<GameRecord>

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Gracze")) {
                    ForEach(players) { player in
                        Text(player.nickname ?? "Nieznany gracz")
                    }
                    .onDelete(perform: deletePlayer)
                }

                Section(header: Text("Historia gier")) {
                    ForEach(gameRecords) { record in
                        Text("\(record.type ?? "Nieznana gra") - \(record.result ?? "Brak wyniku")")
                    }
                }
            }
            .navigationBarTitle("LuckyStrike")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addPlayer) {
                        Label("Dodaj gracza", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addPlayer() {
        let newPlayer = Player(context: viewContext)
        newPlayer.nickname = "Gracz \(Int.random(in: 1...100))"
        newPlayer.balance = 1000

        saveContext()
    }

    private func deletePlayer(at offsets: IndexSet) {
        offsets.map { players[$0] }.forEach(viewContext.delete)
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Nie udało się zapisać danych: \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
