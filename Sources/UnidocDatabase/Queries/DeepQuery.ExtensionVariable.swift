import BSONEncoding
import MongoExpressions
import UnidocRecords

extension DeepQuery
{
    struct ExtensionVariable:MongoExpressionVariable, ExpressibleByStringLiteral
    {
        let name:String

        init(name:String)
        {
            self.name = name
        }
    }
}
extension DeepQuery.ExtensionVariable
{
    var scalars:MongoExpression
    {
        .expr
        {
            $0[.concatArrays] = .init
            {
                for key:BSON.Key in
                [
                    Record.Extension[.conformances],
                    Record.Extension[.features],
                    Record.Extension[.nested],
                    Record.Extension[.subforms],
                ]
                {
                    $0.expr
                    {
                        $0[.coalesce] = (self[key], [] as [Never])
                    }
                }

                $0.append([self[Record.Extension[.culture]]])
            }
        }
    }
    var zones:String
    {
        "$\(Record.Extension[.zones])"
    }
}
extension DeepQuery.ExtensionVariable
{
    func collect(
        _ output:KeyPath<Self, some BSONEncodable>,
        from input:BSON.Key) -> MongoExpression
    {
        .expr
        {
            $0[.setUnion] = .init
            {
                $0.expr
                {
                    $0[.reduce] = .init
                    {
                        $0[.input] = .expr
                        {
                            $0[.map] = .let(self)
                            {
                                $0[.input] = "$\(input)"
                                $0[.in] = self[keyPath: output]
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
        }
    }
}
