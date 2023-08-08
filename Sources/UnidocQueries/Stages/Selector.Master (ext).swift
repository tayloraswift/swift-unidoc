import MongoQL
import Unidoc
import UnidocDatabase
import UnidocSelectors
import UnidocRecords

extension Selector.Master:DatabaseLookupSelector
{
    public
    func lookup(input:Mongo.KeyPath, as output:Mongo.KeyPath) -> Mongo.LookupDocument
    {
        //  Find at least one master record that has a matching url stem,
        //  within the zone of scalars we obtained from the previous stage.
        //  (The stems do not encode snapshot information.)
        .init
        {
            let min:Mongo.Variable<Unidoc.Scalar> = "min"
            let max:Mongo.Variable<Unidoc.Scalar> = "max"

            $0[.from] = Database.Masters.name
            $0[.let] = .init
            {
                $0[let: min] = input / Record.Zone[self.planes.range.min]
                $0[let: max] = input / Record.Zone[self.planes.range.max]
            }
            $0[.pipeline] = .init
            {
                $0.stage
                {
                    $0[.match] = .init
                    {
                        $0[Record.Master[.stem]] = self.stem
                        $0[Record.Master[.hash]] = self.hash
                        $0[.expr] = .expr
                        {
                            $0[.and] =
                            (
                                .expr
                                {
                                    $0[.gte] = (Record.Master[.id], min)
                                },
                                .expr
                                {
                                    $0[.lte] = (Record.Master[.id], max)
                                }
                            )
                        }
                    }
                }
                $0.stage
                {
                    $0[.limit] = 50
                }
            }
            $0[.as] = output
        }
    }
}
