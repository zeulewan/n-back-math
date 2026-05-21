import Foundation

struct ProgressStore {
    private let key = "nBackMath.native.progress.v1"
    private let defaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> GameProgress {
        guard let data = defaults.data(forKey: key) else {
            return GameProgress()
        }

        do {
            var progress = try decoder.decode(GameProgress.self, from: data)
            progress.levelIndex = GameLevel.clampedIndex(progress.levelIndex)
            progress.trimRuns()
            return progress
        } catch {
            return GameProgress()
        }
    }

    func save(_ progress: GameProgress) {
        guard let data = try? encoder.encode(progress) else {
            return
        }

        defaults.set(data, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
