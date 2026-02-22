import BSON
import GitHubAPI
import UnixTime

@available(*, unavailable, message: "Not needed yet.")
struct GitHubCredentials {
    var refresh: GitHubCredential<UnixMillisecond>
    var access: GitHubCredential<UnixMillisecond>

    init(
        refresh: GitHubCredential<UnixMillisecond>,
        access: GitHubCredential<UnixMillisecond>
    ) {
        self.refresh = refresh
        self.access = access
    }
}
@available(*, unavailable, message: "Not needed yet.")
extension GitHubCredentials {
    enum CodingKey: String, Sendable {
        case refresh = "R"
        case access = "A"
    }
}
@available(*, unavailable, message: "Not needed yet.")
extension GitHubCredentials: BSONDocumentEncodable {
    func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.refresh] = self.refresh
        bson[.access] = self.access
    }
}
@available(*, unavailable, message: "Not needed yet.")
extension GitHubCredentials: BSONDocumentDecodable {
    init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            refresh: try bson[.refresh].decode(),
            access: try bson[.access].decode()
        )
    }
}
