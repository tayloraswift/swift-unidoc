extension Repository
{
    @frozen public
    struct Revision:Sendable
    {
        @usableFromInline internal
        typealias Storage = (UInt32, UInt32, UInt32, UInt32, UInt32)

        @usableFromInline internal
        var storage:Storage

        @inlinable internal
        init(storage:Storage = (0, 0, 0, 0, 0))
        {
            self.storage = storage
        }
    }
}
extension Repository.Revision:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        0
    }
    @inlinable public
    var endIndex:Int
    {
        MemoryLayout<Storage>.size
    }
    @inlinable public
    subscript(index:Int) -> UInt8
    {
        get
        {
            precondition(self.indices ~= index, "index out of range")
            return withUnsafeBytes(of: self.storage) { $0[index] }
        }
        set(value)
        {
            precondition(self.indices ~= index, "index out of range")
            withUnsafeMutableBytes(of: &self.storage) { $0[index] = value }
        }
    }
}
extension Repository.Revision:Equatable
{
    @inlinable public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.storage == rhs.storage
    }
}
extension Repository.Revision:Hashable
{
    @inlinable public
    func hash(into hasher:inout Hasher)
    {
        for byte:UInt8 in self
        {
            byte.hash(into: &hasher)
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

        self.init()
        var byte:Int = self.endIndex
        var word:Int = 0
        while byte != self.startIndex
        {
            withUnsafeBytes(of: integerLiteral[word].bigEndian)
            {
                for value:UInt8 in $0.reversed()
                {
                    byte = self.index(before: byte)
                    self[byte] = value

                    if  byte == self.startIndex
                    {
                        break
                    }
                }
            }
            word += 1
        }
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
            for (index, byte):(Int, UInt8) in zip($0.indices, self)
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
        let storage:Storage? = withUnsafeTemporaryAllocation(
            byteCount: MemoryLayout<Storage>.size,
            alignment: MemoryLayout<Storage>.alignment)
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
                return $0.load(as: Storage.self)
            }
            else
            {
                return nil
            }
        }
        if  let storage:Storage
        {
            self.init(storage: storage)
        }
        else
        {
            return nil
        }
    }
}
