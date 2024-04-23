extension URI.Fragment
{
    @frozen public
    enum EncodingSet
    {
    }
}
extension URI.Fragment.EncodingSet:PercentEncodingSet
{
    /// The fragment encoding set is exactly the same as the ``URI/Query.EncodingSet``.
    @inlinable public static
    func contains(_ byte:UInt8) -> Bool
    {
        URI.Query.EncodingSet.contains(byte)
    }
}
