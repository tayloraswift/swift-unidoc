import MongoExpressions

extension DeepQuery.ExtensionList
{
    struct LoopVariable:MongoExpressionVariable, ExpressibleByStringLiteral
    {
        let name:String

        init(name:String)
        {
            self.name = name
        }
    }
}
