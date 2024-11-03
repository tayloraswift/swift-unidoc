import BSON
import MongoDB
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    enum UserAccountQuery:Sendable
    {
        /// Returns the user account information for the currently-authenticated user, checking
        /// the session cookie.
        case current(UserSession.Web)

        /// Returns the user account information for the specified user, performing no
        /// authentication! **THIS QUERY RETURNS SENSITIVE INFORMATION!!!**
        case another(Account)
    }
}
extension Unidoc.UserAccountQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.Users
    public
    typealias Iteration = Mongo.Single<Output>

    @inlinable public
    var collation:Mongo.Collation { .simple }
    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match]
        {
            switch self
            {
            case .current(let session):
                $0[Unidoc.User[.id]] = session.id
                $0[Unidoc.User[.cookie]] = session.cookie

            case .another(let account):
                $0[Unidoc.User[.id]] = account
            }
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
