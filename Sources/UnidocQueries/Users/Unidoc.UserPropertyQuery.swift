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
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.User[.id]] = self.account
        }

        pipeline[stage: .replaceWith] = .init(Output.CodingKey.self)
        {
            $0[.user] = Mongo.Pipeline.ROOT
        }

        pipeline[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.Packages.name
            $0[.localField] = Output[.user] / Unidoc.User[.id]
            $0[.foreignField] = Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.account]
            $0[.pipeline] = .init
            {
                $0[stage: .match] = .init
                {
                    $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.account]]
                    {
                        $0[.exists] = true
                    }
                }

                Unidoc.PackageOutput.extend(pipeline: &$0, from: Mongo.Pipeline.ROOT)
            }
            $0[.as] = Output[.packages]
        }
    }
}
