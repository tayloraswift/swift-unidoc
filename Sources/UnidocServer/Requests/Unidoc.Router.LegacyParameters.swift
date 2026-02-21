import Symbols
import URI

extension Unidoc.Router {
    struct LegacyParameters {
        var overload: Symbol.Decl?
        var from: String?

        private init() {
            self.overload = nil
            self.from = nil
        }
    }
}
extension Unidoc.Router.LegacyParameters {
    init(_ query: __shared URI.Query) {
        self.init()

        for (key, value): (String, String) in query.parameters {
            switch key {
            case "overload":    self.overload = .init(rawValue: value)
            case "from":        self.from = value
            case _:             continue
            }
        }
    }
}
