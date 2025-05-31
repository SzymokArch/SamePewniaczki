//
//  ActivePlayerSection.swift
//  projekt
//
//  Created by macOS on 30/05/2025.
//

import SwiftUI
import CoreData

struct ActivePlayerSection: View {
    var players: FetchedResults<Player>
    @Binding var selectedNickname: String

    var body: some View {
        Section(header: Text("Aktywny gracz")) {
            Picker("Wybierz gracza", selection: $selectedNickname) {
                ForEach(players) { player in
                    Text(player.nickname ?? "Nieznany").tag(player.nickname ?? "")
                }
            }
        }
    }
}
