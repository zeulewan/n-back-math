import Testing
@testable import App

struct MathProblemTests {
    @Test func generatedProblemsStayInSupportedAnswerRange() {
        var generator = SystemRandomNumberGenerator()

        for _ in 0..<100 {
            let problem = MathProblem.random(using: &generator)

            #expect((0...9).contains(problem.left))
            #expect((0...9).contains(problem.right))
            #expect((0...18).contains(problem.answer))
        }
    }
}
