import BSON
import MongoDB
import MongoQL
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct RealmQuery:Equatable, Hashable, Sendable
    {
        public
        let symbol:String

        @usableFromInline
        let user:Unidoc.Account?

        @inlinable public
        init(realm symbol:String, user:Unidoc.Account? = nil)
        {
            self.symbol = symbol
            self.user = user
        }
    }
}
extension Unidoc.RealmQuery:Unidoc.AliasingQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
    public
    typealias CollectionOrigin = Unidoc.DB.RealmAliases
    public
    typealias CollectionTarget = Unidoc.DB.Realms

    @inlinable public static
    var target:Mongo.AnyKeyPath { Output[.metadata] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        if  let user:Unidoc.Account = self.user
        {
            pipeline[stage: .lookup]
            {
                $0[.from] = Unidoc.DB.Users.name
                $0[.pipeline]
                {
                    $0[stage: .match]
                    {
                        $0[Unidoc.User[.id]] = user
                    }
                }
                $0[.as] = Output[.user]
            }
            //  Unbox single-element array.
            pipeline[stage: .set, using: Output.CodingKey.self]
            {
                $0[.user] { $0[.first] = Output[.user] }
            }
        }

        //  It’s not clear to me how this is able to use the partial index even without
        // `$exists` guards, but somehow it does.
        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Packages.name
            $0[.localField] = Self.target / Unidoc.RealmMetadata[.id]
            $0[.foreignField] = Unidoc.PackageMetadata[.realm]
            $0[.pipeline]
            {
                $0[stage: .replaceWith, using: Unidoc.EditionOutput.CodingKey.self]
                {
                    $0[.package] = Mongo.Pipeline.ROOT
                }

                $0.loadEdition(matching: .latest(.release),
                    from: Unidoc.EditionOutput[.package],
                    into: Unidoc.EditionOutput[.edition])
            }
            $0[.as] = Output[.packages]
        }
    }
}
