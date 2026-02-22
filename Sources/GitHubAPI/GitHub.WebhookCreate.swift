import JSON

extension GitHub {
    @frozen public struct WebhookCreate: Sendable {
        public var repo: Repo

        /// Oddly enough, the API does not return the SHA-1 commit associated with the ref.
        public let ref: String
        public let refType: RefType

        public let installation: Int32?

        @inlinable public init(
            repo: Repo,
            ref: String,
            refType: RefType,
            installation: Int32?
        ) {
            self.repo = repo
            self.ref = ref
            self.refType = refType
            self.installation = installation
        }
    }
}
extension GitHub.WebhookCreate: JSONObjectDecodable {
    @frozen public enum CodingKey: String, Sendable {
        case repository
        case ref
        case ref_type

        case installation
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            repo: try json[.repository].decode(),
            ref: try json[.ref].decode(),
            refType: try json[.ref_type].decode(),
            installation: try json[.installation]?.decode(
                using: GitHub.Installation.CodingKey.self
            ) {
                try $0[.id].decode()
            }
        )
    }
}
