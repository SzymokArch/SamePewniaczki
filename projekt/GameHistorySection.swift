//
//  GameHistorySection.swift
//  projekt
//
//  Created by macOS on 30/05/2025.
//

import SwiftUI

struct GameHistorySection: View {
    var records: [GameRecord]
    var playerSelected: Bool

    var body: some View {
        Section(header: Text("Historia gier")) {
            if !playerSelected {
                Text("Wybierz gracza, aby zobaczyć historię gier")
                    .foregroundColor(.secondary)
            } else if records.isEmpty {
                Text("Brak zapisanych gier")
                    .foregroundColor(.secondary)
            } else {
                ForEach(records) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.type ?? "Nieznana gra")
                            .font(.headline)

                        Text(formattedDate(record.date))
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("Wynik: \(record.bet >= 0 ? "+" : "")\(record.bet) PLN")
                            .foregroundColor(record.bet >= 0 ? .green : .red)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Brak daty" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
