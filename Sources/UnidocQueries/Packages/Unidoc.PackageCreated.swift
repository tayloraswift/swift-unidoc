import BSON
import MongoQL
import UnidocDB
import UnixTime

extension Unidoc
{
    /// A predicate that matches all packages whose associated GitHub repositories are owned by
    /// a particular user or organization.
    @frozen public
    struct PackageOwner:Equatable, Hashable, Sendable
    {
        @usableFromInline
        let owner:String
        @usableFromInline
        let limit:Int

        @inlinable
        init(by owner:String, limit:Int)
        {
            self.owner = owner
            self.limit = limit
        }
    }
}
extension Unidoc.PackageOwner:Unidoc.PackagePredicate
{
    @inlinable public
    var hint:Mongo.CollectionIndex? { Unidoc.DB.Packages.indexAccount }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.PackageMetadata[.repo]] { $0[.exists] = true }
            $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.account]] = self.owner
        }

        pipeline[stage: .limit] = self.limit
    }
}

extension Unidoc
{
    /// A predicate that matches all packages whose associated GitHub repositories were created
    /// during a specific timeframe.
    ///
    /// >   Note:
    ///     The name of the type is singular and not plural (`PackagesCreated`) because it is
    ///     meant to be used as a type parameter to `PackagesQuery`, which is plural.
    @frozen public
    struct PackageCreated:Equatable, Hashable, Sendable
    {
        @usableFromInline
        let timeframe:Range<UnixDate>
        @usableFromInline
        let limit:Int

        @inlinable
        init(during timeframe:Range<UnixDate>, limit:Int)
        {
            self.timeframe = timeframe
            self.limit = limit
        }
    }
}
extension Unidoc.PackageCreated:Unidoc.PackagePredicate
{
    @inlinable public
    var hint:Mongo.CollectionIndex? { Unidoc.DB.Packages.indexRepoCreated }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.PackageMetadata[.repo]] { $0[.exists] = true }

            $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]]
            {
                $0[.gte] = BSON.Millisecond.init(UnixInstant.date(self.timeframe.lowerBound))
            }
            $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]]
            {
                $0[.lt] = BSON.Millisecond.init(UnixInstant.date(self.timeframe.upperBound))
            }
        }

        pipeline[stage: .limit] = self.limit
    }
}
