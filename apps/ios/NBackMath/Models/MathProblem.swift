import Foundation

struct MathProblem: Identifiable, Equatable {
    let id = UUID()
    let left: Int
    let operation: ProblemOperator
    let right: Int
    let answer: Int

    var prompt: String {
        "\(left) \(operation.rawValue) \(right)"
    }

    static func random<R: RandomNumberGenerator>(using generator: inout R) -> MathProblem {
        let left = Int.random(in: 0...9, using: &generator)
        let right = Int.random(in: 0...9, using: &generator)

        if Bool.random(using: &generator) {
            let high = max(left, right)
            let low = min(left, right)
            return MathProblem(left: high, operation: .subtraction, right: low, answer: high - low)
        }

        return MathProblem(left: left, operation: .addition, right: right, answer: left + right)
    }
}
