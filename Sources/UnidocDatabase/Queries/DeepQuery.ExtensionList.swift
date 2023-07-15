import BSONEncoding
import MongoBuiltins
import MongoExpressions

extension DeepQuery
{
    struct ExtensionList
    {
        let key:BSON.Key

        init(in key:BSON.Key)
        {
            self.key = key
        }
    }
}
extension DeepQuery.ExtensionList
{
    var scalars:Scalars { .init(self) }
    var zones:Zones { .init(self) }
}
extension DeepQuery.ExtensionList
{
    func join(_ output:(LoopVariable) -> some BSONEncodable) -> Mongo.ReduceDocument
    {
        .init
        {
            $0[.input] = .expr
            {
                let variable:LoopVariable = "self"
                $0[.map] = .let(variable)
                {
                    $0[.input] = "$\(self.key)"
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
