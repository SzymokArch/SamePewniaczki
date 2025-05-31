//
//  AddPlayerSection.swift
//  projekt
//
//  Created by macOS on 30/05/2025.
//

import SwiftUI

struct AddPlayerSection: View {
    @Binding var newPlayerName: String
    var addAction: () -> Void

    var body: some View {
        Section(header: Text("Dodaj nowego gracza")) {
            TextField("Nazwa gracza", text: $newPlayerName)
            Button("Dodaj", action: addAction)
                .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}
