extension URI.Query
{
    @frozen public
    enum EncodingSet
    {
    }
}
extension URI.Query.EncodingSet:PercentEncodingSet
{
    @inlinable public static
    func contains(_ byte:UInt8) -> Bool
    {
        switch Unicode.Scalar.init(byte)
        {
        case "/":           false
        case "?":           false
        case let codepoint: URI.Path.Component.EncodingSet.contains(codepoint: codepoint)
        }
    }
}
