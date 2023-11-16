public
protocol PercentEncodingSet
{
    static
    func contains(_ byte:UInt8) -> Bool
}
extension PercentEncodingSet
{
    @inlinable internal static
    func encode(_ string:String) -> String
    {
        func hex(uppercasing value:UInt8) -> UInt8
        {
            (value < 10 ? 0x30 : 0x37) + value
        }

        var encoded:[UInt8] = []
            encoded.reserveCapacity(string.utf8.underestimatedCount)
        for byte:UInt8 in string.utf8
        {
            if  Self.contains(byte)
            {
                encoded.append(0x25) // '%'
                encoded.append(hex(uppercasing: byte >> 4))
                encoded.append(hex(uppercasing: byte & 0x0f))
            }
            else
            {
                encoded.append(byte)
            }
        }
        return .init(decoding: encoded, as: Unicode.ASCII.self)
    }
}
