//
//  MainMenuView.swift
//  projekt
//
//  Created by macOS on 10/05/2025.
//

import SwiftUI

struct MainMenuView: View {
    @AppStorage("darkModeEnbled") private var darkModeEnbled: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("table")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("Same Pewniaczki")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)

                    NavigationLink("Blackjack", destination: BlackjackGameView(darkModeEnabled: $darkModeEnbled))
                        .buttonStyle(.borderedProminent)

                    NavigationLink("Plinko", destination: PlinkoGameView(darkModeEnabled: $darkModeEnbled))
                        .buttonStyle(.borderedProminent)

                    NavigationLink("Ustawienia", destination: SettingsView())
                        .buttonStyle(.borderedProminent)

                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    MainMenuView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
