import Testing
import Foundation
@testable import App

struct GameViewModelTests {
    @MainActor
    @Test func adjustsLevelAndPersistsSelection() throws {
        let suiteName = "n-back-math-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = ProgressStore(defaults: defaults)
        let model = GameViewModel(store: store)

        model.adjustLevel(by: 1)

        #expect(model.levelIndex == 1)
        #expect(model.level.label == "Fast 1-back")
        #expect(store.load().levelIndex == 1)
    }
}
