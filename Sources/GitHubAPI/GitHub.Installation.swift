import JSON

extension GitHub {
    @frozen public struct Installation: Equatable, Sendable {
        public let id: Int32
        public let app: Int32
        public let account: UserInvite

        @inlinable public init(id: Int32, app: Int32, account: UserInvite) {
            self.id = id
            self.app = app
            self.account = account
        }
    }
}
extension GitHub.Installation {
    /// There are a lot more fields in the API response, but we only need the ID.
    @frozen public enum CodingKey: String, Sendable {
        case id
        case app_id
        case account
    }
}
extension GitHub.Installation: JSONObjectDecodable {
    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            id: try json[.id].decode(),
            app: try json[.app_id].decode(),
            account: try json[.account].decode()
        )
    }
}
