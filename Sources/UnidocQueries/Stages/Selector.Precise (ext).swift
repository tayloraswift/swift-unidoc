import FNV1
import MongoQL
import Unidoc
import UnidocDatabase
import UnidocSelectors
import UnidocRecords

extension Selector.Precise:DatabaseLookupSelector
{
    public
    func lookup(input:Mongo.KeyPath, as output:Mongo.KeyPath) -> Mongo.LookupDocument
    {
        .init
        {
            let min:Mongo.Variable<Unidoc.Scalar> = "min"
            let max:Mongo.Variable<Unidoc.Scalar> = "max"

            $0[.from] = Database.Masters.name
            $0[.let] = .init
            {
                $0[let: min] = input / Record.Zone[.planes_min]
                $0[let: max] = input / Record.Zone[.planes_max]
            }
            $0[.pipeline] = .init
            {
                $0.stage
                {
                    $0[.match] = .init
                    {
                        $0[.expr] = .expr
                        {
                            let hash:FNV24.Extended = .init(hashing: "\(self.symbol)")

                            //  The first three of these clauses should be able to use
                            //  a compound index.
                            $0[.and] =
                            (
                                .expr
                                {
                                    $0[.eq] = (Record.Master[.hash], hash)
                                },
                                .expr
                                {
                                    $0[.gte] = (Record.Master[.id], min)
                                },
                                .expr
                                {
                                    $0[.lte] = (Record.Master[.id], max)
                                },
                                .expr
                                {
                                    $0[.eq] = (Record.Master[.symbol], self.symbol)
                                }
                            )
                        }
                    }
                }
                $0.stage
                {
                    $0[.limit] = 1
                }
            }
            $0[.as] = output
        }
    }
}
