extension Markdown.AttributeEncoder
{
    @inlinable public
    subscript<Value>(_ key:Markdown.Bytecode.Attribute) -> Markdown.Outlinable<Value>?
        where Value:CustomStringConvertible
    {
        get { nil }
        set (value)
        {
            switch value
            {
            case nil:                       break
            case .inline(let value):        self[key] = value.description
            case .outlined(let reference):  self[key] = reference
            }
        }
    }
}
