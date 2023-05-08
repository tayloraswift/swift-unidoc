extension Repository
{
    @frozen public
    struct Revision:Hashable, Equatable, Sendable
    {
        /// The bytes of this revision hash, in little-endian order. It can be
        /// 40 to 64 bytes long.
        public
        let littleEndian:[UInt8]

        @inlinable public
        init(littleEndian:[UInt8])
        {
            self.littleEndian = littleEndian
        }
    }
}
extension Repository.Revision:CustomStringConvertible
{
    public
    var description:String
    {
        .init(unsafeUninitializedCapacity: 2 * self.littleEndian.count)
        {
            func digit(remainder:UInt8) -> UInt8
            {
                (remainder < 10 ? 0x30 : 0x61 - 10) &+ remainder
            }
            for (i, byte):(Int, UInt8) in self.littleEndian.reversed().enumerated()
            {
                $0[2 * i    ] = digit(remainder: byte >> 4)
                $0[2 * i + 1] = digit(remainder: byte & 0x0f)
            }
            return $0.count
        }
    }
}
extension Repository.Revision:LosslessStringConvertible
{
    public
    init?(_ description:String)
    {
        self.init(description[...])
    }
    public
    init?(_ description:Substring)
    {
        var buffer:[UInt8] = []
            buffer.reserveCapacity(40)
        var input:ReversedCollection<Substring>.Iterator = description.reversed().makeIterator()
        while let low:Character = input.next()
        {
            if  let low:Int = low.hexDigitValue,
                let high:Int = input.next()?.hexDigitValue
            {
                buffer.append(.init(high << 4 | low))
            }
            else
            {
                return nil
            }
        }
        self.init(littleEndian: buffer)
    }
}
