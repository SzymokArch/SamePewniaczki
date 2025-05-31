//
//  DatabaseFunctions.swift
//  projekt
//
//  Created by macOS on 30/05/2025.
//

import Foundation
import CoreData
import SwiftUI

func addPlayer(named name: String, in context: NSManagedObjectContext) {
    let trimmedName = name.trimmingCharacters(in: .whitespaces)
    guard !trimmedName.isEmpty else { return }

    let newPlayer = Player(context: context)
    newPlayer.nickname = trimmedName
    newPlayer.balance = 1000

    saveContext(context)
}

func renamePlayer(from oldName: String, to newName: String, in context: NSManagedObjectContext, players: FetchedResults<Player>) {
    let trimmedName = newName.trimmingCharacters(in: .whitespaces)
    guard let player = players.first(where: { $0.nickname == oldName }) else { return }
    guard !trimmedName.isEmpty else { return }

    player.nickname = trimmedName

    saveContext(context)
}

func saveContext(_ context: NSManagedObjectContext) {
    do {
        try context.save()
    } catch {
        let nsError = error as NSError
        fatalError("Nie udało się zapisać danych: \(nsError), \(nsError.userInfo)")
    }
}
