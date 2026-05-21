import Testing
@testable import App

struct GameLevelTests {
    @Test func createsSlowAndFastLevelsForEachNBack() {
        #expect(GameLevel.all.count == 24)
        #expect(GameLevel.all.first?.label == "Slow 1-back")
        #expect(GameLevel.all[1].label == "Fast 1-back")
        #expect(GameLevel.all.last?.label == "Fast 12-back")
    }

    @Test(arguments: [
        (-10, 0),
        (0, 0),
        (23, 23),
        (99, 23),
    ])
    func clampsLevelIndexes(input: Int, expected: Int) {
        #expect(GameLevel.clampedIndex(input) == expected)
    }
}
