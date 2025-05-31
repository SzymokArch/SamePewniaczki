import SwiftUI
import CoreData

struct PlayerManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.nickname, ascending: true)],
        animation: .default
    ) private var players: FetchedResults<Player>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GameRecord.date, ascending: false)],
        animation: .default
    ) private var gameRecords: FetchedResults<GameRecord>

    @AppStorage("selectedPlayerNickname") private var selectedPlayerNickname: String = ""

    @State private var newPlayerName: String = ""
    @State private var renameText: String = ""

    private var selectedPlayer: Player? {
        players.first(where: { $0.nickname == selectedPlayerNickname })
    }

    private var filteredGameRecords: [GameRecord] {
        guard let player = selectedPlayer else { return [] }
        return gameRecords.filter { $0.player == player }
    }

    var body: some View {
        Form {
            ActivePlayerSection(players: players, selectedNickname: $selectedPlayerNickname)
            RenamePlayerSection(renameText: $renameText, renameAction: renameAction)
            AddPlayerSection(newPlayerName: $newPlayerName, addAction: addAction)
            GameHistorySection(records: filteredGameRecords, playerSelected: selectedPlayer != nil)
        }
        .navigationTitle("Gracze")
    }

    private func addAction() {
        addPlayer(named: newPlayerName, in: viewContext)
        newPlayerName = ""
    }
    
    private func renameAction() {
        renamePlayer(from: selectedPlayerNickname, to: renameText, in: viewContext, players: players)
        selectedPlayerNickname = renameText.trimmingCharacters(in: .whitespaces)
        renameText = ""
    }
}

#Preview {
    PlayerManagementView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
