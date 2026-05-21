import Foundation

struct GameProgress: Codable, Equatable {
    static let maximumSavedRuns = 80

    var version = 1
    var levelIndex = 0
    var runs: [RunRecord] = []

    mutating func trimRuns() {
        runs = Array(runs.prefix(Self.maximumSavedRuns))
    }
}
