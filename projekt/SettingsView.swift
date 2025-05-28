//
//  SettingsView.swift
//  projekt
//
//  Created by macOS on 10/05/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("nickname") private var nickname: String = ""
    @AppStorage("darkModeEnbled") private var darkModeEnbled: Bool = false
    @AppStorage("ballColorHex") private var ballColorHex: String = "#FF0000"
    
    @State private var selectedColor: Color = .red

    var body: some View {
        Form {
            Section(header: Text("Użytkownik")) {
                TextField("Nickname", text: $nickname)
            }

            Section(header: Text("Ustawienia")) {
                Toggle("Tryb ciemny", isOn: $darkModeEnbled)
                ColorPicker("Kolor piłki", selection: $selectedColor)
                    .onChange(of: selectedColor) {
                        ballColorHex = selectedColor.toHex() ?? "#FF0000"
                    }
            }
        }
        .onAppear {
                    selectedColor = Color(hex: ballColorHex) ?? .red
                }
        .preferredColorScheme(darkModeEnbled ? .dark : .light)
        .navigationTitle("Ustawienia")
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }

    func toHex() -> String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    SettingsView()
}
