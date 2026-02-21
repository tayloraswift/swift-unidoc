import URI

extension Unidoc.Router {
    struct AuthParameters {
        /// Only used for testing, never sent by GitHub.
        var token: String?
        /// Defined and sent by GitHub.
        var state: String?
        /// Defined and sent by GitHub.
        var code: String?
        /// Defined by us and parroted back by GitHub.
        var from: String?

        var flow: Unidoc.LoginFlow?

        private init() {
            self.token = nil
            self.state = nil
            self.code = nil
            self.from = nil
            self.flow = nil
        }
    }
}
extension Unidoc.Router.AuthParameters {
    init(_ query: __shared URI.Query) {
        self.init()

        for (key, value): (String, String) in query.parameters {
            switch key {
            case "token":   self.token = value
            case "state":   self.state = value
            case "code":    self.code = value
            case "from":    self.from = value
            case "flow":    self.flow = .init(value)
            case _:         continue
            }
        }
    }
}
