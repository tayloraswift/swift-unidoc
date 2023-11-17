extension URI.Fragment
{
    @frozen public
    enum EncodingSet
    {
    }
}
extension URI.Fragment.EncodingSet:PercentEncodingSet
{
    @inlinable public static
    func contains(_ byte:UInt8) -> Bool
    {
        byte == 0x3F ? false : URI.Query.EncodingSet.contains(byte)
    }
}
