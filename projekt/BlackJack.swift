import Foundation
import SwiftUI

enum Suit: String, CaseIterable {
    case hearts = "♥️"
    case diamonds = "♦️"
    case clubs = "♣️"
    case spades = "♠️"

    var color: Color {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .clubs, .spades:
            return .black
        }
    }
}

struct Card: Identifiable {
    let id = UUID()
    let value: Int
    let display: String
    let suit: Suit
}


class Deck {
    private var cards: [Card] = []

    init() {
        reset()
    }

    func reset() {
        cards = []
        
        let faces = ["A": 11, "2": 2, "3": 3, "4": 4, "5": 5,
                     "6": 6, "7": 7, "8": 8, "9": 9, "10": 10,
                     "J": 10, "Q": 10, "K": 10]

        for suit in Suit.allCases {
            for (display, value) in faces {
                cards.append(Card(value: value, display: display, suit: suit))
            }
        }

        cards.shuffle()
    }

    func drawCard() -> Card? {
        if cards.isEmpty { reset() }
        return cards.popLast()
    }
}

class BlackjackGame: ObservableObject {
    @Published var playerHand: [Card] = []
    @Published var dealerHand: [Card] = []
    @Published var message: String = ""
    @Published var isGameOver = true
    var selectedPlayer: Player?
    
    func configure(with player: Player) {
        self.selectedPlayer = player
    }
    
    var currentBet: Int32 = 10
    
    private var deck = Deck()
    
    var onGameEnd: ((Int32) -> Void)? = nil
    
    func startGame(withBet bet: Int32) -> Bool {
        if !isGameOver {
            message = "Poprzednia gra nie została zakończona!"
            return false
        }

        if selectedPlayer!.balance < bet {
            message = "Nie masz wystarczających środków!"
            return false
        }
        
        currentBet = bet
        isGameOver = false
        playerHand = []
        dealerHand = []
        message = ""

        deck.reset()
        playerHand.append(deck.drawCard()!)
        playerHand.append(deck.drawCard()!)
        dealerHand.append(deck.drawCard()!)

        checkPlayerBust()
        return true
    }

    func checkPlayerBust() {
        if handValue(playerHand) > 21 {
            selectedPlayer!.balance  -= currentBet
            message = "Przegrałeś! 🪦 -\(currentBet)"
            onGameEnd?(-currentBet)
            isGameOver = true
        }
    }

    func playerStands() {
        while handValue(dealerHand) < 17 {
            if let card = deck.drawCard() {
                dealerHand.append(card)
            }
        }

        let playerTotal = handValue(playerHand)
        let dealerTotal = handValue(dealerHand)

        if dealerTotal > 21 || playerTotal > dealerTotal {
            selectedPlayer!.balance  += currentBet
                message = "Wygrałeś! 🎉 +\(currentBet)"
                onGameEnd?(currentBet)
            } else if dealerTotal == playerTotal {
                message = "Remis 🤝"
                onGameEnd?(0)
            } else {
                selectedPlayer!.balance  -= currentBet
                message = "Krupier wygrał 😞 -\(currentBet)"
                onGameEnd?(-currentBet)
            }
            isGameOver = true
    }

    func playerHits() {
        guard !isGameOver else { return }  // blokada po zakończeniu rundy
        guard let card = deck.drawCard() else { return }
        playerHand.append(card)
        checkPlayerBust()
    }

    func handValue(_ hand: [Card]) -> Int {
        var total = hand.map { $0.value }.reduce(0, +)
        var aceCount = hand.filter { $0.display == "A" }.count
        
        while total > 21 && aceCount > 0 {
            total -= 10
            aceCount -= 1
        }
        return total
    }
}
