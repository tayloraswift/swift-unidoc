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
        let session:UserSession.Web

        @inlinable public
        init(session:UserSession.Web)
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
    typealias Iteration = Mongo.Single<Output>

    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match]
        {
            $0[Unidoc.User[.id]] = self.session.id
            $0[Unidoc.User[.cookie]] = self.session.cookie
        }

        pipeline[stage: .facet, using: Output.CodingKey.self]
        {
            $0[.user]
            $0[.organizations]
            {
                $0[stage: .unwind] = Unidoc.User[.access]
                $0[stage: .lookup]
                {
                    $0[.from] = Unidoc.DB.Users.name
                    $0[.localField] = Unidoc.User[.access]
                    $0[.foreignField] = Unidoc.User[.id]
                    $0[.as] = Unidoc.User[.access]
                }
                $0[stage: .unwind] = Unidoc.User[.access]
                $0[stage: .replaceWith] = Unidoc.User[.access]
            }
        }

        pipeline[stage: .unwind] = Output[.user]
    }
}
