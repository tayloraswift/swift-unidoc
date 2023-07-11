import BSON
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
}
