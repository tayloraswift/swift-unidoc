extension Repository
{
    @frozen public
    struct Revision:Hashable, Equatable, Sendable
    {
        public
        let hash:UInt8x20

        @inlinable public
        init(hash:UInt8x20)
        {
            self.hash = hash
        }
    }
}
extension Repository.Revision:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:StaticBigInt)
    {
        precondition(integerLiteral.signum() >= 0,
            "revision literal cannot be negative")
        precondition(integerLiteral.bitWidth <= 161, // +1 bit for “sign” bit
            "revision literal overflows UInt8x20 (bit width: \(integerLiteral.bitWidth))")

        var hash:UInt8x20 = .init()
        var byte:Int = hash.endIndex
        var word:Int = 0
        while byte != hash.startIndex
        {
            withUnsafeBytes(of: integerLiteral[word].bigEndian)
            {
                for value:UInt8 in $0.reversed()
                {
                    byte = hash.index(before: byte)
                    hash[byte] = value

                    if  byte == hash.startIndex
                    {
                        break
                    }
                }
            }
            word += 1
        }
        self.init(hash: hash)
    }
}
extension Repository.Revision:CustomStringConvertible
{
    public
    var description:String
    {
        .init(unsafeUninitializedCapacity: 40)
        {
            func digit(remainder:UInt8) -> UInt8
            {
                (remainder < 10 ? 0x30 : 0x61 - 10) &+ remainder
            }
            for (index, byte):(Int, UInt8) in zip($0.indices, self.hash)
            {
                $0[2 * index    ] = digit(remainder: byte >> 4)
                $0[2 * index + 1] = digit(remainder: byte & 0x0f)
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
        let hash:UInt8x20? = withUnsafeTemporaryAllocation(
            byteCount: MemoryLayout<UInt8x20.Storage>.size,
            alignment: MemoryLayout<UInt8x20.Storage>.alignment)
        {
            var input:IndexingIterator<Substring> = description.makeIterator()
            for index:Int in $0.indices
            {
                if  let high:Int = input.next()?.hexDigitValue,
                    let low:Int = input.next()?.hexDigitValue
                {
                    $0[index] = .init(high << 4 | low)
                }
                else
                {
                    return nil
                }
            }
            if  case nil = input.next()
            {
                return .init(storage: $0.load(as: UInt8x20.Storage.self))
            }
            else
            {
                return nil
            }
        }
        if  let hash:UInt8x20
        {
            self.init(hash: hash)
        }
        else
        {
            return nil
        }
    }
}
