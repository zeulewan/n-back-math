import Foundation
import Testing
@testable import App

struct ProgressStoreTests {
    @Test func savesAndLoadsProgressFromInjectedDefaults() throws {
        let suiteName = "n-back-math-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = ProgressStore(defaults: defaults)
        let run = RunRecord(
            id: UUID(),
            completedAt: Date(),
            levelIndex: 3,
            levelLabel: "Fast 2-back",
            nBack: 2,
            speedLabel: "Fast",
            answerSeconds: 3,
            rounds: 24,
            correct: 20,
            missed: 4,
            accuracy: 83,
            bestStreak: 7,
            durationSeconds: 90
        )
        let progress = GameProgress(version: 1, levelIndex: 3, runs: [run])

        store.save(progress)

        #expect(store.load() == progress)
    }

    @Test func clearRemovesSavedProgress() throws {
        let suiteName = "n-back-math-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = ProgressStore(defaults: defaults)
        store.save(GameProgress(version: 1, levelIndex: 4, runs: []))
        store.clear()

        #expect(store.load() == GameProgress())
    }
}
