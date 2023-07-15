import BSONEncoding
import MongoBuiltins
import MongoExpressions
import UnidocRecords

extension DeepQuery.ExtensionList
{
    struct Scalars
    {
        let extensions:DeepQuery.ExtensionList

        init(_ extensions:DeepQuery.ExtensionList)
        {
            self.extensions = extensions
        }
    }
}
extension DeepQuery.ExtensionList.Scalars
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr
        {
            $0[.reduce] = self.extensions.join
            {
                (current:DeepQuery.ExtensionList.LoopVariable) -> MongoExpression in .expr
                {
                    $0[.concatArrays] = .init
                    {
                        for key:Record.Extension.CodingKey in
                        [
                            .conformances,
                            .features,
                            .nested,
                            .subforms,
                        ]
                        {
                            $0.expr
                            {
                                $0[.coalesce] = (current[Record.Extension[key]], [] as [Never])
                            }
                        }

                        $0.append([current[Record.Extension[.culture]]])
                    }
                }
            }
        }
    }
}
