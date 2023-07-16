import BSONEncoding
import MongoBuiltins
import MongoExpressions
import UnidocRecords

extension DeepQuery
{
    struct List<Element>
    {
        let key:BSON.Key

        init(in key:BSON.Key)
        {
            self.key = key
        }
    }
}
extension DeepQuery.List<Record.Extension>
{
    var scalars:Scalars { .init(self) }
    var zones:Zones { .init(self) }
}
extension DeepQuery.List
{
    func join(
        _ output:(DeepQuery.Variable<Element>) -> some BSONEncodable) -> Mongo.ReduceDocument
    {
        .init
        {
            $0[.input] = .expr
            {
                let variable:DeepQuery.Variable<Element> = "self"
                $0[.map] = .let(variable)
                {
                    $0[.input] = .expr { $0[.coalesce] = ("$\(self.key)", [] as [Never]) }
                    $0[.in] = output(variable)
                }
            }
            $0[.initialValue] = [] as [Never]
            $0[.in] = .expr
            {
                $0[.concatArrays] = ("$$value", "$$this")
            }
        }
    }
}
