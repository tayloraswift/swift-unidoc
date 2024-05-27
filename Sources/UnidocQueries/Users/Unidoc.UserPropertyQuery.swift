import BSON
import MongoDB
import UnidocDB
import UnidocRecords

extension Unidoc
{
    /// Returns the user account information for the specified user, and all the packages and
    /// realms the user owns.
    @frozen public
    struct UserPropertyQuery:Sendable
    {
        public
        let account:Account

        @inlinable public
        init(account:Account)
        {
            self.account = account
        }
    }
}
extension Unidoc.UserPropertyQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.Packages

    public
    typealias Collation = SimpleCollation

    public
    typealias Iteration = Mongo.Single<Output>

    @inlinable public
    var hint:Mongo.CollectionIndex? { Unidoc.DB.Packages.indexAccount }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.account]] = self.account
            $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.account]]
            {
                $0[.exists] = true
            }
        }

        pipeline[stage: .facet] = .init
        {
            $0[Output[.packages]] = .init
            {
                $0[stage: .replaceWith] = .init
                {
                    $0[Unidoc.EditionOutput[.package]] = Mongo.Pipeline.ROOT
                }

                $0.loadEdition(matching: .latest(.release),
                    from: Unidoc.EditionOutput[.package],
                    into: Unidoc.EditionOutput[.edition])
            }
        }

        let account:Mongo.Variable<Unidoc.Scalar> = "account"

        pipeline[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.Users.name
            $0[.let] = .init
            {
                $0[let: account] = self.account
            }
            $0[.pipeline] = .init
            {
                $0[stage: .match] = .init
                {
                    $0[.expr] { $0[.eq] = (Unidoc.User[.id], account) }
                }
            }
            $0[.as] = Output[.user]
        }

        //  Unbox zero- or one-element array.
        pipeline[stage: .set] = .init
        {
            $0[Output[.user]] = .expr { $0[.first] = Output[.user] }
        }
    }
}
