//
//  projektApp.swift
//  projekt
//
//  Created by macOS on 10/05/2025.
//

import SwiftUI

@main
struct projektApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
