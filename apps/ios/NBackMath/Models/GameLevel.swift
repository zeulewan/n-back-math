import Foundation

struct GameLevel: Identifiable, Codable, Equatable {
    static let maximumNBack = 12

    let index: Int
    let nBack: Int
    let speed: GameSpeed

    var id: String {
        "\(speed.rawValue)-\(nBack)"
    }

    var label: String {
        "\(speed.label) \(nBack)-back"
    }

    var shortLabel: String {
        "\(speed.label.prefix(1))\(nBack)"
    }

    var answerSeconds: TimeInterval {
        speed.answerSeconds
    }

    static let all: [GameLevel] = (1...maximumNBack).flatMap { nBack in
        GameSpeed.allCases.map { speed in
            let index = ((nBack - 1) * GameSpeed.allCases.count) + GameSpeed.allCases.firstIndex(of: speed)!
            return GameLevel(index: index, nBack: nBack, speed: speed)
        }
    }

    static func clampedIndex(_ index: Int) -> Int {
        min(max(index, 0), all.count - 1)
    }
}
