//
//  PlinkoGameLogic.swift
//  projekt
//
//  Created by macOS on 31/05/2025.
//

import SwiftUI
import CoreData

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
}

let pinSpacing: CGFloat = 40
let rows = 8
let columns = 8
let basketCount = 9
let screenWidth: CGFloat = 360
let screenHeight: CGFloat = 600
let ballDropCost: Int32 = 30
let basketValue: [Int32] = [10, 20, 40, 60, 100, 60, 40, 20, 10]

class PlinkoGameLogic: ObservableObject {
    @Published var pins: [Pin] = []
    @Published var balls: [Ball] = []
    @Published var baskets: [Basket] = []
    @Published var initialBalance: Int32 = 0
    
    func initGame(selectedPlayer: Player?) {
        setupGame()
        if let player = selectedPlayer {
            initialBalance = player.balance
        }
    }
    
    func setupGame() {
        pins.removeAll()
        for row in 0..<rows {
            for col in 0..<columns {
                let xOffset = (row % 2 == 0) ? pinSpacing / 2 : 0
                let x = CGFloat(col) * pinSpacing + xOffset + 20
                let y = CGFloat(row) * pinSpacing + 80
                pins.append(Pin(x: x, y: y))
            }
        }
        
        baskets = (0..<basketCount).map { i in
            let x = CGFloat(i) * (screenWidth / CGFloat(basketCount)) + (screenWidth / CGFloat(basketCount) / 2)
            return Basket(x: x)
        }
    }

    func applyPhysics(for ball: inout Ball) {
        if ball.ay > -1
        {
            ball.ay -= 1
            if ball.ay < -1
            {
                ball.ay = -1
            }
        }
        
        if ball.ax > 0
        {
            ball.ax -= 1
            if ball.ax < 0
            {
                ball.ax = 0
            }
        }
        else if ball.ax < 0
        {
            ball.ax += 1
            if ball.ax > 0
            {
                ball.ax = 0
            }
        }
        
        ball.dy -= ball.ay
        ball.dx += ball.ax
        
        ball.x += ball.dx
        
        if ball.x < 6 || ball.x > screenWidth - 6
        {
            ball.dx = -ball.dx/2
            ball.ax = -ball.ax
        }
        
        ball.y += ball.dy
    }
    
    func applyColisionPhysics(for b: inout Ball, _dx: CGFloat, _dy: CGFloat) {
        b.dy = 0
        b.dx = 0
        
        let total : CGFloat = abs(_dx) + abs(_dy)
        var randY : CGFloat = CGFloat.random(in: 0.1...0.3)
        
        if _dy < 0 { randY = -randY }
        
        b.ay = (2.2 * (CGFloat(1) + _dy / total) + randY)
        
        let randX = CGFloat.random(in: 2.0...2.4)
        if _dx > 0 {
            b.ax = -randX * (CGFloat(1) + _dx / total)
        }
        else if _dx == 0 {
            b.ax = randX * (CGFloat(1) - _dx / total)
            if Bool.random() {
                b.ax = -b.ax
            }
        }
        else {
            b.ax = randX * (CGFloat(1) - _dx / total)
        }
    }
    
    func collisionCheck(for ball: inout Ball, dx: CGFloat, dy: CGFloat) -> (_: Bool, _: CGFloat, _: CGFloat)
    {
        for pin in self.pins {
            let dx = pin.x - ball.x
            let dy = pin.y - ball.y
            let distance = sqrt(dx * dx + dy * dy)
            if distance < 10 {
                let overlap = distance - 10
                ball.x += overlap * (dx) / distance
                ball.y += overlap * (dy) / distance
                return (true, dx, dy)
            }
        }
        return (false, 0, 0)
    }
    
    func dropBall(selectedPlayer: Player?) {
        if let player = selectedPlayer {
            if player.balance < ballDropCost { return }
            player.balance -= ballDropCost
        }
        
        let newBall = Ball(x: screenWidth / 2, y: 10, dx: 0, dy: 0, ax: 0, ay: 0)
        let ballId = newBall.id
        
        balls.append(newBall)
        
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            guard let index = self.balls.firstIndex(where: { $0.id == ballId }) else {
                timer.invalidate()
                return
            }
            var b = self.balls[index]
            var wasColided : Bool = false
            var _dx : CGFloat = 0
            var _dy : CGFloat = 0
            
            (wasColided, _dx, _dy) = self.collisionCheck(for: &b, dx: _dx, dy: _dy)
            
            if wasColided {
                self.applyColisionPhysics(for: &b, _dx: _dx, _dy: _dy)
            }
            
            self.applyPhysics(for: &b)
            
            self.balls[index] = b
            
            if b.y >= screenHeight - 70 || b.y < -10 {
                timer.invalidate()
                let index = Int((b.x / screenWidth) * CGFloat(basketCount))
                if index >= 0 && index < self.baskets.count {
                    if let player = selectedPlayer {
                        player.balance += basketValue[index]
                    }
                }
            }
        }
    }
}
