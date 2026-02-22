import ArgumentParser

extension SSGC {
    @frozen public enum ValidationBehavior: CaseIterable {
        /// Documentation warnings will be promoted to errors, and will fail the build.
        case warningsAsErrors
        /// Documentation errors will fail the build, but warnings will not.
        case failOnErrors
        /// Documentation errors will be reported as errors, but will not fail the build.
        case ignoreErrors
        /// Documentation errors will be demoted to warnings, and will not fail the build.
        case demoteErrors
    }
}
extension SSGC.ValidationBehavior: CustomStringConvertible {
    public var description: String {
        switch self {
        case .warningsAsErrors: "warnings-as-errors"
        case .failOnErrors:     "fail-on-errors"
        case .ignoreErrors:     "ignore-errors"
        case .demoteErrors:     "demote-errors"
        }
    }
}
extension SSGC.ValidationBehavior: LosslessStringConvertible {
    public init?(_ description: String) {
        switch description {
        case "warnings-as-errors":  self = .warningsAsErrors
        case "fail-on-errors":      self = .failOnErrors
        case "ignore-errors":       self = .ignoreErrors
        case "demote-errors":       self = .demoteErrors
        default:                    return nil
        }
    }
}
extension SSGC.ValidationBehavior: ExpressibleByArgument {
}
