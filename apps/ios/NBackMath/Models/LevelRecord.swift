import Foundation

struct LevelRecord: Identifiable {
    let level: GameLevel
    let runs: Int
    let bestAccuracy: Int
    let bestStreak: Int

    var id: String {
        level.id
    }

    var isComplete: Bool {
        bestAccuracy >= 80
    }
}
