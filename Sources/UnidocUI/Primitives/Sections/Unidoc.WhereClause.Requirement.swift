import HTML
import LexicalPaths
import Signatures

extension Unidoc.WhereClause {
    struct Requirement {
        let parameter: String
        let what: GenericOperator
        let whom: HTML.Link<UnqualifiedPath>

        init(parameter: String, is what: GenericOperator, to whom: HTML.Link<UnqualifiedPath>) {
            self.parameter = parameter
            self.what = what
            self.whom = whom
        }
    }
}
extension Unidoc.WhereClause.Requirement: CustomStringConvertible {
    var description: String {
        switch self.what {
        case .conformer:    "\(self.parameter):\(self.whom)"
        case .subclass:     "\(self.parameter):\(self.whom)"
        case .equal:        "\(self.parameter) == \(self.whom)"
        }
    }
}
extension Unidoc.WhereClause.Requirement: HTML.OutputStreamable {
    static func += (code: inout HTML.ContentEncoder, self: Self) {
        code[.span] { $0.highlight = .typealias } = self.parameter

        switch self.what {
        case .conformer:    code += ":"
        case .subclass:     code += ":"
        case .equal:        code += " == "
        }

        code += self.whom
    }
}
