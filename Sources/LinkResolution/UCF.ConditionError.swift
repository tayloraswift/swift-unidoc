import UCF

extension UCF {
    @frozen @usableFromInline enum ConditionError: Error {
        case value(Condition, String)
        case valueExpected(Condition)
    }
}
extension UCF.ConditionError: CustomStringConvertible {
    @usableFromInline var description: String {
        switch self {
        case .value(let condition, let value):
            "value '\(value)' is invalid for condition '\(condition)'"
        case .valueExpected(let condition):
            "value expected for condition '\(condition)'"
        }
    }
}
