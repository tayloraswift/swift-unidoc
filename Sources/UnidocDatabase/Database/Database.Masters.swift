import MongoDB
import Unidoc
import UnidocSelectors
import UnidocRecords

extension Database
{
    public
    struct Masters
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Masters:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "masters" }

    typealias ElementID = Unidoc.Scalar

    static
    let indexes:[Mongo.CreateIndexStatement] =
    [
        //  If a snapshot contains a hash collision, insertion will fail.
        //  Because the index is prefixed with the stem, we expect this to be
        //  extraordinarily rare.
        //  See:
        //  forums.swift.org/t/how-does-docc-mitigate-fnv-1-hash-collisions/65673
        .init
        {
            $0[.unique] = true
            $0[.name] = "zone,stem,hash"

            $0[.collation] = Database.collation
            $0[.key] = .init
            {
                $0[Volume.Master[.zone]] = (+)
                $0[Volume.Master[.stem]] = (+)
                $0[Volume.Master[.hash]] = (+)
            }
            //  This limits the index to masters with a stem. This is all of them,
            //  except for ``Volume.Master.File``.
            $0[.partialFilterExpression] = .init
            {
                $0[Volume.Master[.stem]] = .init { $0[.exists] = true }
            }
        },
        .init
        {
            $0[.unique] = true
            $0[.name] = "hash,id"

            $0[.collation] = Database.collation
            $0[.key] = .init
            {
                $0[Volume.Master[.hash]] = (+)
                $0[Volume.Master[.id]] = (+)
            }
        },
    ]
}
