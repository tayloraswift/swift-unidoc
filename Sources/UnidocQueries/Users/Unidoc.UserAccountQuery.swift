import BSON
import MongoDB
import UnidocDB

extension Unidoc
{
    /// Returns the user account information for the currently-authenticated user.
    @frozen public
    struct UserAccountQuery:Sendable
    {
        public
        let session:UserSession

        @inlinable public
        init(session:UserSession)
        {
            self.session = session
        }
    }
}
extension Unidoc.UserAccountQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.Users

    public
    typealias Collation = SimpleCollation

    public
    typealias Iteration = Mongo.Single<Unidoc.User>

    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.User[.id]] = self.session.account
            $0[Unidoc.User[.cookie]] = self.session.cookie
        }
    }
}
