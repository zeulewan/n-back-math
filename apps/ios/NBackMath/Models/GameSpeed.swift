import Foundation

enum GameSpeed: String, Codable, CaseIterable {
    case slow
    case fast

    var label: String {
        switch self {
        case .slow:
            return "Slow"
        case .fast:
            return "Fast"
        }
    }

    var answerSeconds: TimeInterval {
        switch self {
        case .slow:
            return 4
        case .fast:
            return 3
        }
    }
}
