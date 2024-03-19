import BSON
import MongoDB
import UnidocDB

extension Unidoc
{
    @frozen public
    struct UserQuery:Sendable
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
extension Unidoc.UserQuery:Mongo.PipelineQuery
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
