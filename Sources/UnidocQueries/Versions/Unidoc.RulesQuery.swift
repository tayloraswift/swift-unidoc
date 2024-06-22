import BSON
import MongoDB
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct RulesQuery:Equatable, Hashable, Sendable
    {
        public
        let symbol:Symbol.Package
        public
        let user:Account?

        @inlinable public
        init(symbol:Symbol.Package, as user:Account?)
        {
            self.symbol = symbol
            self.user = user
        }
    }
}
extension Unidoc.RulesQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Unidoc.RulesOutput>
}
extension Unidoc.RulesQuery:Unidoc.AliasingQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    public
    typealias CollectionTarget = Unidoc.DB.Packages

    @inlinable public static
    var target:Mongo.AnyKeyPath { Unidoc.RulesOutput[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .set, using: Unidoc.RulesOutput.CodingKey.self]
        {
            $0[.editors]
            {
                $0[.coalesce] =
                (
                    Unidoc.RulesOutput[.package] / Unidoc.PackageMetadata[.editors],
                    [] as [Never]
                )
            }
            $0[.owner]
            {
                $0[.coalesce] =
                (
                    Unidoc.RulesOutput[.package]
                        / Unidoc.PackageMetadata[.repo]
                        / Unidoc.PackageRepo[.account],
                    BSON.Max.init()
                )
            }
        }

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Users.name
            $0[.localField] = Unidoc.RulesOutput[.editors]
            $0[.foreignField] = Unidoc.User[.id]
            $0[.as] = Unidoc.RulesOutput[.editors]
        }

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Users.name
            $0[.localField] = Unidoc.RulesOutput[.owner]
            $0[.foreignField] = Unidoc.User[.access]
            $0[.as] = Unidoc.RulesOutput[.members]
        }

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Users.name
            $0[.localField] = Unidoc.RulesOutput[.owner]
            $0[.foreignField] = Unidoc.User[.id]
            $0[.as] = Unidoc.RulesOutput[.owner]
        }

        //  Unbox single-element array.
        pipeline[stage: .set, using: Unidoc.RulesOutput.CodingKey.self]
        {
            $0[.owner] { $0[.first] = Unidoc.RulesOutput[.owner] }
        }

        guard
        let user:Unidoc.Account = self.user
        else
        {
            return
        }

        pipeline.loadUser(matching: user, as: Unidoc.RulesOutput[.user])
    }
}
