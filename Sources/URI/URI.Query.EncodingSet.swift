extension URI.Query
{
    enum EncodingSet
    {
    }
}
extension URI.Query.EncodingSet:PercentEncodingSet
{
    static
    func contains(_ byte:UInt8) -> Bool
    {
        byte == 0x3f ? false : URI.Path.Component.EncodingSet.contains(byte)
    }
}
