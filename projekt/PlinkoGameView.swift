//
//  ContentView.swift
//  plinko
//
//  Created by macOS on 16/04/2025.
//

import SwiftUI

struct Pin: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
}

struct Ball: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var dx: CGFloat
    var dy: CGFloat
    var ax: CGFloat
    var ay: CGFloat
}

struct Basket: Identifiable {
    let id = UUID()
    let x: CGFloat
    var count: Int = 0
}

struct PlinkoGameView: View {
    @Binding var darkModeEnabled: Bool
    @AppStorage("ballColorHex") private var ballColorHex: String = "#FF0000"

    var ballColor: Color {
        Color(hex: ballColorHex) ?? .red
    }
    
    @State private var pins: [Pin] = []
    @State private var balls: [Ball] = []
    @State private var baskets: [Basket] = []
    @State private var ballDropped = false
    @State private var s : Int = 0
    @State private var spawnTimer: Timer?
    
    let pinSpacing: CGFloat = 40
    let rows = 8
    let columns = 8
    let basketCount = 9
    let screenWidth: CGFloat = 360
    let screenHeight: CGFloat = 600
    
    var backgroundColor: Color {
        darkModeEnabled ? Color.black : Color.white
    }

    var pinColor: Color {
        darkModeEnabled ? Color(white: 0.7) : Color.gray
    }

    var basketColor: Color {
        darkModeEnabled ? Color.blue.opacity(0.7) : Color.blue
    }
    
    var body: some View {
        VStack {
            /*if ball != nil {
                Text("\(ball!.ay), \(ball!.ax)")
            }*/
            Text("Tap")
                .frame(width: 100, height: 80)
                .background(Color.clear)
                .border(Color.gray, width: 2)
                .contentShape(Rectangle())
                .onTapGesture {
                    dropBall()
                }
                .onLongPressGesture(minimumDuration: 0.2, pressing: { isPressing in
                    if isPressing {
                        // Start spawn timer
                        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                            dropBall()
                        }
                    } else {
                        // Stop timer when released
                        spawnTimer?.invalidate()
                        spawnTimer = nil
                    }
                }, perform: {
                    // dodatkowe działanie przy zakończeniu długiego naciśnięcia
                })
            ZStack{
                ForEach(pins) { pin in
                    Circle()
                        .fill(pinColor)
                        .frame(width: 8, height: 8)
                        .position(x: pin.x, y: pin.y)
                }
                
                ForEach(baskets) { basket in
                    VStack {
                        Rectangle()
                            .fill(basketColor)
                            .frame(width: 2, height: 20)
                        Text("\(basket.count)")
                            .font(.caption)
                    }
                    .position(x: basket.x, y: screenHeight - 40)
                }
                
                //if let _balls = balls {
                ForEach(balls) { ball in
                    Circle()
                        .fill(ballColor)
                        .frame(width: 12, height: 12)
                        .position(x: ball.x, y: ball.y)
                }
                /*Circle()
                 .fill(Color.red)
                 .frame(width: 12, height: 12)
                 .position(x: ball.x, y: ball.y)
                 .animation(.linear(duration: 0.05), value: ball.y)*/
                //}
            }
        }
        .frame(width: screenWidth, height: screenHeight)
        .background(backgroundColor)
        .onAppear(perform: setupGame)
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
    
    func setupGame() {
        // Setup pins
        pins.removeAll()
        for row in 0..<rows {
            for col in 0..<columns {
                let xOffset = (row % 2 == 0) ? pinSpacing / 2 : 0
                let x = CGFloat(col) * pinSpacing + xOffset + 20
                let y = CGFloat(row) * pinSpacing + 80
                pins.append(Pin(x: x, y: y))
            }
        }
        
        // Setup baskets
        baskets = (0..<basketCount).map { i in
            let x = CGFloat(i) * (screenWidth / CGFloat(basketCount)) + (screenWidth / CGFloat(basketCount) / 2)
            return Basket(x: x)
        }
    }

     func dropBall() {
         //guard !ballDropped else { return }
         ballDropped = true
         s += 1

         let newBall = Ball(x: screenWidth / 2, y: 10, dx: 0, dy: 0, ax: 0, ay: 0)
         balls.append(newBall)
         let ballId = newBall.id
         
         // ax = 1 brak ruchu w poziomie,
         // ay = 1 brak ruchu w pionie
         let x_acceleration : CGFloat = 2.3
         let y_acceleration : CGFloat = 1

         Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
             guard let index = balls.firstIndex(where: { $0.id == ballId }) else {
                 timer.invalidate()
                 return
             }
             var b = balls[index]
             
             var wasColided : Bool = false
             var _dx : CGFloat = 0
             var _dy : CGFloat = 0
             // Sprawdzenie kolizji z pinami
             for pin in pins {
                 let dx = pin.x - b.x
                 let dy = pin.y - b.y
                 /*if sqrt(dx * dx + dy * dy) < 10 {
                     wasColided = true
                 }*/
                 let distance = sqrt(dx * dx + dy * dy)
                 if distance < 10 {
                     wasColided = true
                     _dx = dx
                     _dy = dy
                     let overlap = distance - 10
                     b.x += overlap * (dx) / distance
                     b.y += overlap * (dy) / distance
                 }
             }
             
             let x1a : CGFloat = (_dx < 0) ? -_dx : _dx
             let y1a : CGFloat = (_dy < 0) ? -_dy : _dy
             
             let div : CGFloat = x1a + y1a
             
             if !wasColided
             {
                 // Ruch w dół (grawitacja)
                 
             }
             else
             {
                 b.dy = 0//b.dy * (y1 / div) * 0.9
                 b.dx = 0//b.dx * (x1 / div) * 0.9
                 //let bounce = CGFloat(3) //CGFloat.random(in: -3...3)
                 //b.dx += bounce
                 //b.dx = max(min(b.dx, 3), -3)
                 //b.dy = 1//
                 /*if y1 > 0
                 {
                     b.ay = -y_acceleration * (CGFloat(1) + (y1 / div)/40)
                 }
                 else
                 {
                     b.ay = y_acceleration * (CGFloat(1) - (y1 / div)/40)
                 }*/
                 var rand : CGFloat = CGFloat.random(in: 0.1...0.3)
                 
                 if _dy < 0
                 {
                     rand = -rand
                 }
                 
                 b.ay = (2.2 * (CGFloat(1) + _dy / div) + rand)//1.3
                 
                 rand = CGFloat.random(in: 2.0...2.4)
                 if _dx > 0
                 {
                     b.ax = -rand * (CGFloat(1) + _dx / div)//1.3
                 }
                 else if _dx == 0
                 {
                     b.ax = rand * (CGFloat(1) - _dx / div)//1.3
                     if Bool.random()
                     {
                         b.ax = -b.ax
                     }
                 }
                 else
                 {
                     b.ax = rand * (CGFloat(1) - _dx / div)//1.3
                 }
                 //b.ax = CGFloat.random(in: -2...2)
             }
             
             if b.ay > -1
             {
                 //b.dy += b.ay
                 b.ay -= 1
                 if b.ay < -1
                 {
                     b.ay = -1
                 }
             }
             /*else if b.ay < 0
             {
                 //b.dy += b.ay
                 b.ay += 1
             }*/
             
             if b.ax > 0
             {
                 //b.dy += b.ay
                 b.ax -= 1
                 if b.ax < 0
                 {
                     b.ax = 0
                 }
             }
             else if b.ax < 0
             {
                 //b.dy += b.ay
                 b.ax += 1
                 if b.ax > 0
                 {
                     b.ax = 0
                 }
             }

             b.dy -= b.ay
             b.dx += b.ax
             // Ruch poziomy z inercją
             b.x += b.dx
             
             if b.x < 6 || b.x > screenWidth - 6
             {
                 b.dx = -b.dx/2
                 b.ax = -b.ax
             }
             
             //b.x = max(6, min(screenWidth - 6, b.x))
             b.y += b.dy

             balls[index] = b

             if b.y >= screenHeight - 40 || b.y < -10 {
                 timer.invalidate()
                 let index = Int((b.x / screenWidth) * CGFloat(basketCount))
                 if index >= 0 && index < baskets.count {
                     baskets[index].count += 1
                 }
                 ballDropped = false
             }
         }
     }
}

#Preview {
    PlinkoGameView(darkModeEnabled: .constant(false))
}

