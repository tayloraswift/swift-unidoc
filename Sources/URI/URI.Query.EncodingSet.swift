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
        byte == 0x3f ? false : URI.Path.Component.EncodingSet.contains(byte)
    }
}
