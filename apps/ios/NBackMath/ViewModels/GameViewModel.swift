import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    static let totalRounds = 24
    private static let appStoreScreenshotArgument = "--app-store-screenshot"
    private static let statsScreenshotArgument = "--screenshot-tab=stats"

    @Published private(set) var progress: GameProgress
    @Published var levelIndex: Int
    @Published private(set) var phase: GamePhase = .idle
    @Published private(set) var isGameActive = false
    @Published private(set) var acceptingAnswer = false
    @Published private(set) var problemText = "N-Back Math"
    @Published private(set) var answerText = ""
    @Published private(set) var round = 0
    @Published private(set) var correct = 0
    @Published private(set) var missed = 0
    @Published private(set) var lastOutcome: GameOutcome?
    @Published var timerProgress = 1.0

    private let store: ProgressStore
    private var task: Task<Void, Never>?
    private var generator = SystemRandomNumberGenerator()
    private var displayStep = 0
    private var answeredQuestions = 0
    private var streak = 0
    private var maxStreak = 0
    private var problems: [MathProblem] = []
    private var currentTarget: MathProblem?
    private var runStartedAt: Date?

    var level: GameLevel {
        GameLevel.all[GameLevel.clampedIndex(levelIndex)]
    }

    var canAdjustLevel: Bool {
        isGameActive == false
    }

    var canClearAnswer: Bool {
        acceptingAnswer && answerText.isEmpty == false
    }

    var primaryButtonTitle: String {
        isResetState ? "Reset" : "Start"
    }

    var primaryButtonSystemImage: String {
        if isGameActive {
            return "stop.fill"
        }

        return phase == .finished ? "arrow.clockwise" : "play.fill"
    }

    var isResetState: Bool {
        isGameActive || phase == .finished
    }

    var visibleAnswer: String {
        answerText.isEmpty ? " " : answerText
    }

    var lifetimeAccuracy: Int {
        accuracy(correct: progress.runs.reduce(0) { $0 + $1.correct },
                 total: progress.runs.reduce(0) { $0 + $1.rounds })
    }

    var bestAccuracy: Int {
        progress.runs.map(\.accuracy).max() ?? 0
    }

    var bestStreak: Int {
        progress.runs.map(\.bestStreak).max() ?? 0
    }

    init(store: ProgressStore = ProgressStore()) {
        self.store = store
        let arguments = ProcessInfo.processInfo.arguments
        let isAppStoreScreenshot = arguments.contains(Self.appStoreScreenshotArgument)
        let isStatsScreenshot = isAppStoreScreenshot && arguments.contains(Self.statsScreenshotArgument)

        var loadedProgress = isStatsScreenshot ? Self.screenshotProgress() : store.load()
        if isAppStoreScreenshot {
            loadedProgress.levelIndex = 4
        }

        progress = loadedProgress
        levelIndex = loadedProgress.levelIndex

        if isAppStoreScreenshot && isStatsScreenshot == false {
            prepareScreenshotState()
        }
    }

    deinit {
        task?.cancel()
    }

    func primaryAction() {
        if isResetState {
            resetGame()
        } else {
            startGame()
        }
    }

    func adjustLevel(by delta: Int) {
        guard canAdjustLevel else {
            return
        }

        let nextIndex = GameLevel.clampedIndex(levelIndex + delta)
        guard nextIndex != levelIndex else {
            return
        }

        levelIndex = nextIndex
        progress.levelIndex = nextIndex
        store.save(progress)
    }

    func chooseLevel(_ record: LevelRecord) {
        guard canAdjustLevel else {
            return
        }

        levelIndex = record.level.index
        progress.levelIndex = record.level.index
        store.save(progress)
    }

    func startGame() {
        cancelTask()
        isGameActive = true
        acceptingAnswer = false
        phase = .ready
        displayStep = 0
        answeredQuestions = 0
        round = 0
        correct = 0
        missed = 0
        streak = 0
        maxStreak = 0
        problems = []
        currentTarget = nil
        answerText = ""
        lastOutcome = nil
        problemText = "Ready"
        timerProgress = 1
        runStartedAt = Date()
        progress.levelIndex = levelIndex
        store.save(progress)
        scheduleNextRound(after: 0.7)
    }

    func resetGame() {
        cancelTask()
        isGameActive = false
        acceptingAnswer = false
        phase = .idle
        displayStep = 0
        answeredQuestions = 0
        round = 0
        correct = 0
        missed = 0
        streak = 0
        maxStreak = 0
        problems = []
        currentTarget = nil
        answerText = ""
        lastOutcome = nil
        problemText = "N-Back Math"
        timerProgress = 1
        runStartedAt = nil
    }

    func appendDigit(_ digit: Int) {
        guard acceptingAnswer else {
            return
        }

        if answerText == "0" {
            answerText = String(digit)
        } else if answerText.count < 2 {
            answerText.append(String(digit))
        }

        if Int(answerText) == currentTarget?.answer {
            submitAnswer()
        }
    }

    func clearAnswer() {
        guard canClearAnswer else {
            return
        }

        answerText = ""
    }

    func clearProgress() {
        guard isGameActive == false else {
            return
        }

        store.clear()
        progress = GameProgress()
        levelIndex = 0
        resetGame()
    }

    func levelRecords() -> [LevelRecord] {
        GameLevel.all.map { level in
            let runs = progress.runs.filter { $0.levelIndex == level.index }
            return LevelRecord(
                level: level,
                runs: runs.count,
                bestAccuracy: runs.map(\.accuracy).max() ?? 0,
                bestStreak: runs.map(\.bestStreak).max() ?? 0
            )
        }
    }

    private func nextRound() {
        if answeredQuestions >= Self.totalRounds {
            finishGame()
            return
        }

        displayStep += 1
        answerText = ""
        let problem = MathProblem.random(using: &generator)
        problems.append(problem)
        problemText = problem.prompt
        currentTarget = nil
        startTimer(duration: level.answerSeconds)

        if displayStep <= level.nBack {
            phase = .memorize
            acceptingAnswer = false
            scheduleNextRound(after: level.answerSeconds)
            return
        }

        phase = .answering
        acceptingAnswer = true
        currentTarget = problems[displayStep - level.nBack - 1]
        round = answeredQuestions + 1
        scheduleSubmit(after: level.answerSeconds)
    }

    private func submitAnswer() {
        guard acceptingAnswer, let currentTarget else {
            return
        }

        cancelTask()
        acceptingAnswer = false
        answeredQuestions += 1
        round = answeredQuestions
        timerProgress = 0

        if Int(answerText) == currentTarget.answer {
            correct += 1
            streak += 1
            maxStreak = max(maxStreak, streak)
            lastOutcome = .correct
        } else {
            missed += 1
            streak = 0
            lastOutcome = .missed
        }

        answerText = ""
        nextRound()
    }

    private func finishGame() {
        cancelTask()
        isGameActive = false
        acceptingAnswer = false
        phase = .finished
        problemText = "Done"
        timerProgress = 1
        recordRun()
    }

    private func recordRun() {
        let duration = runStartedAt.map { Date().timeIntervalSince($0) } ?? 0
        let record = RunRecord(
            id: UUID(),
            completedAt: Date(),
            levelIndex: level.index,
            levelLabel: level.label,
            nBack: level.nBack,
            speedLabel: level.speed.label,
            answerSeconds: level.answerSeconds,
            rounds: Self.totalRounds,
            correct: correct,
            missed: missed,
            accuracy: accuracy(correct: correct, total: Self.totalRounds),
            bestStreak: maxStreak,
            durationSeconds: duration
        )

        progress.runs.insert(record, at: 0)
        progress.trimRuns()
        store.save(progress)
    }

    private func scheduleNextRound(after seconds: TimeInterval) {
        task = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            guard Task.isCancelled == false else {
                return
            }

            self?.nextRound()
        }
    }

    private func scheduleSubmit(after seconds: TimeInterval) {
        task = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            guard Task.isCancelled == false else {
                return
            }

            self?.submitAnswer()
        }
    }

    private func startTimer(duration: TimeInterval) {
        timerProgress = 1

        withAnimation(.linear(duration: duration)) {
            timerProgress = 0
        }
    }

    private func cancelTask() {
        task?.cancel()
        task = nil
    }

    private func prepareScreenshotState() {
        phase = .answering
        isGameActive = true
        acceptingAnswer = true
        currentTarget = MathProblem(left: 8, operation: .addition, right: 7, answer: 15)
        problemText = "8 + 7"
        round = 9
        correct = 7
        missed = 1
        lastOutcome = .correct
        timerProgress = 0.62
        answerText = "1"
    }

    private static func screenshotProgress(now: Date = Date()) -> GameProgress {
        let seeds: [(levelIndex: Int, correct: Int, bestStreak: Int, daysAgo: Int)] = [
            (4, 22, 10, 0),
            (5, 21, 8, 1),
            (2, 23, 11, 2),
            (3, 20, 7, 3),
            (6, 19, 6, 4),
            (1, 22, 9, 5),
            (0, 23, 11, 6),
            (7, 18, 5, 7),
            (8, 20, 6, 8),
            (9, 17, 4, 9),
            (10, 21, 8, 10),
            (11, 19, 6, 11),
        ]

        let runs = seeds.enumerated().map { index, seed in
            let level = GameLevel.all[GameLevel.clampedIndex(seed.levelIndex)]
            let rounds = Self.totalRounds
            let missed = rounds - seed.correct
            let idSuffix = String(format: "%012d", index + 1)

            return RunRecord(
                id: UUID(uuidString: "00000000-0000-0000-0000-\(idSuffix)") ?? UUID(),
                completedAt: now.addingTimeInterval(-TimeInterval(seed.daysAgo * 86_400)),
                levelIndex: level.index,
                levelLabel: level.label,
                nBack: level.nBack,
                speedLabel: level.speed.label,
                answerSeconds: level.answerSeconds,
                rounds: rounds,
                correct: seed.correct,
                missed: missed,
                accuracy: Int((Double(seed.correct) / Double(rounds) * 100).rounded()),
                bestStreak: seed.bestStreak,
                durationSeconds: TimeInterval(rounds) * level.answerSeconds
            )
        }

        return GameProgress(levelIndex: 4, runs: runs)
    }

    private func accuracy(correct: Int, total: Int) -> Int {
        guard total > 0 else {
            return 0
        }

        return Int((Double(correct) / Double(total) * 100).rounded())
    }
}
