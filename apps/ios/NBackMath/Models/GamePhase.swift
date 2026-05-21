import Foundation

enum GamePhase: String {
    case idle
    case ready
    case memorize
    case answering
    case finished

    var label: String {
        switch self {
        case .idle:
            return "Idle"
        case .ready:
            return "Ready"
        case .memorize:
            return "Watch"
        case .answering:
            return "Answer"
        case .finished:
            return "Done"
        }
    }
}
