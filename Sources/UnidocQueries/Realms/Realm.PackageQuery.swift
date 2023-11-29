import MongoDB
import MongoQL
import Symbols
import UnidocDB
import UnidocRecords

extension Realm
{
    public
    typealias PackageQuery = _RealmPackageQuery
}

/// The name of this protocol is ``Realm.PackageQuery``.
public
protocol _RealmPackageQuery:Mongo.PipelineQuery<UnidocDatabase.PackageAliases>
    where Collation == SimpleCollation
{
    /// The field to store the ``Realm.Package`` document in.
    static
    var package:Mongo.KeyPath { get }

    var package:Symbol.Package { get }

    func extend(pipeline:inout Mongo.PipelineEncoder)
}
extension Realm.PackageQuery
{
    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        defer
        {
            self.extend(pipeline: &pipeline)
        }

        pipeline[.match] = .init
        {
            $0[Realm.PackageAlias[.id]] = self.package
        }

        pipeline[.limit] = 1

        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Packages.name
            $0[.localField] = Realm.PackageAlias[.coordinate]
            $0[.foreignField] = Realm.Package[.id]
            $0[.as] = Self.package
        }

        pipeline[.project] = .init
        {
            $0[Self.package] = true
        }

        pipeline[.unwind] = Self.package
    }
}
