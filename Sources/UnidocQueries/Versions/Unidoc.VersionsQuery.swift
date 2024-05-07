import MongoDB
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct VersionsQuery:Equatable, Hashable, Sendable
    {
        public
        let symbol:Symbol.Package
        public
        let filter:Predicate
        public
        let user:Unidoc.Account?

        @inlinable public
        init(symbol:Symbol.Package, filter:Predicate, as user:Unidoc.Account? = nil)
        {
            self.symbol = symbol
            self.filter = filter
            self.user = user
        }
    }
}
extension Unidoc.VersionsQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidoc.VersionsQuery:Unidoc.AliasingQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    public
    typealias CollectionTarget = Unidoc.DB.Packages

    @inlinable public static
    var target:Mongo.AnyKeyPath { Output[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        switch self.filter
        {
        case .tags(limit: let limit, page: let page, series: let series):
            pipeline.loadTags(series: series,
                limit: limit,
                skip: limit * page,
                from: Self.target,
                into: Output[.versions_list])

        case .none(limit: let limit):
            let prereleases:Mongo.AnyKeyPath = "prereleases"
            let releases:Mongo.AnyKeyPath = "releases"

            pipeline.loadTags(series: .prerelease,
                limit: limit,
                from: Self.target,
                into: prereleases)

            pipeline.loadTags(series: .release,
                limit: limit,
                from: Self.target,
                into: releases)

            //  Concatenate the two lists.
            pipeline[stage: .set] = .init
            {
                $0[Output[.versions_list]] = .expr
                {
                    $0[.concatArrays] = (prereleases, releases)
                }
            }
            pipeline[stage: .unset] = [prereleases, releases]

            pipeline.loadTopOfTree(from: Self.target, into: Output[.versions_top])

            //  Lookup other aliases for this package.
            let aliases:Mongo.List<Unidoc.PackageAlias, Mongo.AnyKeyPath> = .init(
                in: Output[.aliases])

            pipeline[stage: .lookup] = .init
            {
                $0[.from] = Unidoc.DB.PackageAliases.name
                $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
                $0[.foreignField] = Unidoc.PackageAlias[.coordinate]
                $0[.as] = aliases.expression
            }

            pipeline[stage: .set] = .init
            {
                $0[Output[.aliases]] = .expr { $0[.map] = aliases.map { $0[.id] } }
            }

            //  Lookup the associated build.
            pipeline[stage: .lookup] = .init
            {
                $0[.from] = Unidoc.DB.PackageBuilds.name
                $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
                $0[.foreignField] = Unidoc.BuildMetadata[.id]
                $0[.as] = Output[.build]
            }
            //  Lookup the associated realm.
            pipeline[stage: .lookup] = .init
            {
                $0[.from] = Unidoc.DB.Realms.name
                $0[.localField] = Self.target / Unidoc.PackageMetadata[.realm]
                $0[.foreignField] = Unidoc.RealmMetadata[.id]
                $0[.as] = Output[.realm]
            }

            //  Unbox single-element arrays.
            pipeline[stage: .set] = .init
            {
                $0[Output[.build]] = .expr { $0[.first] = Output[.build] }
                $0[Output[.realm]] = .expr { $0[.first] = Output[.realm] }
            }
        }

        if  let user:Unidoc.Account = self.user
        {
            //  Lookup the querying user.
            pipeline[stage: .lookup] = .init
            {
                $0[.from] = Unidoc.DB.Users.name
                $0[.pipeline] = .init
                {
                    $0[stage: .match] = .init
                    {
                        $0[Unidoc.User[.id]] = user
                    }
                }
                $0[.as] = Output[.user]
            }

            //  Unbox single-element array.
            pipeline[stage: .set] = .init
            {
                $0[Output[.user]] = .expr { $0[.first] = Output[.user] }
            }
        }
    }
}
