import JSON

extension GitHub {
    @frozen public struct RepoInvite: Identifiable, Equatable, Sendable {
        public let id: Int32
        public let name: String
        public let node: Node
        public let visibility: RepoVisibility

        @inlinable public init(
            id: Int32,
            name: String,
            node: Node,
            visibility: RepoVisibility
        ) {
            self.id = id
            self.name = name
            self.node = node
            self.visibility = visibility
        }
    }
}
extension GitHub.RepoInvite: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case id
        case node_id
        case name
        case `private`
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            id: try json[.id].decode(),
            name: try json[.name].decode(),
            node: try json[.node_id].decode(),
            visibility: try json[.private].decode(to: Bool.self) ? .private : .public
        )
    }
}
