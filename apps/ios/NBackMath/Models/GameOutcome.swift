import Foundation

enum GameOutcome {
    case correct
    case missed

    var label: String {
        switch self {
        case .correct:
            return "OK"
        case .missed:
            return "Miss"
        }
    }
}
