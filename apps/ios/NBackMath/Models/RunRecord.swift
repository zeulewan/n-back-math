import Foundation

struct RunRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let completedAt: Date
    let levelIndex: Int
    let levelLabel: String
    let nBack: Int
    let speedLabel: String
    let answerSeconds: TimeInterval
    let rounds: Int
    let correct: Int
    let missed: Int
    let accuracy: Int
    let bestStreak: Int
    let durationSeconds: TimeInterval
}
