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
        let limitTags:Int
        public
        let limitBranches:Int
        public
        let limitDependents:Int
        public
        let limitBuilds:Int
        public
        let user:Account?

        @inlinable public
        init(symbol:Symbol.Package,
            limitTags:Int,
            limitBranches:Int = 32,
            limitDependents:Int = 32,
            limitBuilds:Int = 8,
            as user:Account? = nil)
        {
            self.symbol = symbol
            self.limitTags = limitTags
            self.limitBranches = limitBranches
            self.limitDependents = limitDependents
            self.limitBuilds = limitBuilds
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
        let prereleases:Mongo.AnyKeyPath = "prereleases"
        let releases:Mongo.AnyKeyPath = "releases"

        pipeline.loadTags(matching: .latest(.prerelease),
            limit: self.limitTags,
            from: Self.target,
            into: prereleases)

        pipeline.loadTags(matching: .latest(.release),
            limit: self.limitTags,
            from: Self.target,
            into: releases)

        pipeline.loadBranches(limit: self.limitBranches,
            from: Self.target,
            into: Output[.branches])

        //  Concatenate the two lists.
        pipeline[stage: .set, using: Output.CodingKey.self]
        {
            $0[.versions] { $0[.concatArrays] = (prereleases, releases) }
        }
        pipeline[stage: .unset] = [prereleases, releases]

        //  Lookup other aliases for this package.
        let aliases:Mongo.List<Unidoc.PackageAlias, Mongo.AnyKeyPath> = .init(
            in: Output[.aliases])

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.PackageAliases.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.PackageAlias[.coordinate]
            $0[.as] = aliases.expression
        }

        pipeline[stage: .set, using: Output.CodingKey.self]
        {
            $0[.aliases] { $0[.map] = aliases.map { $0[.id] } }
        }

        Unidoc.ConsumersPageSegment.bridge(pipeline: &pipeline,
            limit: self.limitDependents,
            from: Self.target,
            into: Output[.dependents])

        Unidoc.CompleteBuildsPageSegment.bridge(pipeline: &pipeline,
            limit: self.limitBuilds,
            from: Self.target,
            into: Output[.recentBuilds])

        //  Lookup any queued or in-progress builds.
        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.PendingBuilds.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.PendingBuild[.package]
            $0[.as] = Output[.pendingBuilds]
        }
        //  Lookup the associated realm.
        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Realms.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.realm]
            $0[.foreignField] = Unidoc.RealmMetadata[.id]
            $0[.as] = Output[.realm]
        }
        //  Lookup the associated crawling ticket.
        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.CrawlingTickets.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.CrawlingTicket<Unidoc.Package>[.id]
            $0[.as] = Output[.ticket]
        }

        //  Unbox single-element arrays.
        pipeline[stage: .set, using: Output.CodingKey.self]
        {
            $0[.realm] { $0[.first] = Output[.realm] }
            $0[.ticket] { $0[.first] = Output[.ticket] }
        }

        if  let id:Unidoc.Account = self.user
        {
            //  Lookup the querying user.
            pipeline.loadUser(matching: id, as: Output[.user])
        }
    }
}
