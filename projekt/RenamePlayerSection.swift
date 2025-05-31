//
//  RenamePlayerSection.swift
//  projekt
//
//  Created by macOS on 30/05/2025.
//

import SwiftUI

struct RenamePlayerSection: View {
    @Binding var renameText: String
    var renameAction: () -> Void

    var body: some View {
        Section(header: Text("Zmień nazwę gracza")) {
            TextField("Nowa nazwa", text: $renameText)
            Button("Zmień nazwę", action: renameAction)
                .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}
