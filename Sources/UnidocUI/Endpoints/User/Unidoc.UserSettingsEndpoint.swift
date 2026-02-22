import HTTP
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnidocRender
import URI

extension Unidoc {
    @frozen public struct UserSettingsEndpoint {
        public let query: UserAccountQuery
        public var value: UserAccountQuery.Output?

        @inlinable public init(query: UserAccountQuery) {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.UserSettingsEndpoint {
    @inlinable public static subscript(account: Unidoc.Account?) -> URI {
        var uri: URI = Unidoc.ServerRoot.account.uri
        if  let account: Unidoc.Account {
            uri.path.append("\(account)")
        }
        return uri
    }
}
extension Unidoc.UserSettingsEndpoint: Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint {
    @inlinable public static var replica: Mongo.ReadPreference { .nearest }
}
extension Unidoc.UserSettingsEndpoint: HTTP.ServerEndpoint {
    public __consuming func response(as format: Unidoc.RenderFormat) -> HTTP.ServerResponse {
        self.response(as: format, admin: false)
    }
}
extension Unidoc.UserSettingsEndpoint {
    public __consuming func response(
        as format: Unidoc.RenderFormat,
        admin: Bool
    ) -> HTTP.ServerResponse {
        guard
        let output: Unidoc.UserAccountQuery.Output = self.value else {
            return .notFound("No such user")
        }

        let userSettingsPage: Unidoc.UserSettingsPage = .init(
            user: output.user,
            organizations: output.organizations,
            location: Self[admin ? output.user.id : nil]
        )
        return .ok(userSettingsPage.resource(format: format))
    }
}
