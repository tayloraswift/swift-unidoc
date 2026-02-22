import URI

extension Unidoc.UserConfigOperation {
    enum Update {
        case generateKey(for: Unidoc.Account)
    }
}
extension Unidoc.UserConfigOperation.Update: URI.QueryDecodable {
    init?(parameters: borrowing [String: String]) {
        if  let account: String = parameters["generate-api-key"],
            let account: Unidoc.Account = .init(account) {
            self = .generateKey(for: account)
        } else {
            return nil
        }
    }
}
