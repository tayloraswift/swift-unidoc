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
        let user:Unidoc.User.ID?

        @inlinable public
        init(realm symbol:String, user:Unidoc.User.ID? = nil)
        {
            self.symbol = symbol
            self.user = user
        }
    }
}
extension Unidoc.RealmQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidoc.RealmQuery:Unidoc.AliasingQuery
{
    public
    typealias CollectionOrigin = UnidocDatabase.RealmAliases
    public
    typealias CollectionTarget = UnidocDatabase.Realms

    @inlinable public static
    var target:Mongo.KeyPath { Output[.metadata] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        if  let user:Unidoc.User.ID = self.user
        {
            pipeline[.lookup] = .init
            {
                $0[.from] = UnidocDatabase.Users.name
                $0[.pipeline] = .init
                {
                    $0[.match] = .init
                    {
                        $0[Unidoc.User[.id]] = user
                    }
                }
                $0[.as] = Output[.user]
            }
            //  Unbox single-element array.
            pipeline[.set] = .init
            {
                $0[Output[.user]] = .expr { $0[.first] = Output[.user] }
            }
        }

        //  This *should* be able to use the partial index even without `$exists` guards,
        //  as `_id` is always present.
        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Packages.name
            $0[.localField] = Self.target / Unidoc.RealmMetadata[.id]
            $0[.foreignField] = Unidoc.PackageMetadata[.realm]
            $0[.as] = Output[.packages]
        }
    }
}
