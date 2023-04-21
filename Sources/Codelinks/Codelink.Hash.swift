extension Codelink
{
    @frozen public
    struct Hash:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        let bits:UInt32

        @inlinable public
        init(bits:UInt32)
        {
            self.bits = bits
        }
    }
}
extension Codelink.Hash
{
    @inlinable public
    var value:UInt32
    {
        self.bits
    }
}
extension Codelink.Hash
{
    init?(parsing string:inout Substring)
    {
        while   let last:Character = string.last
        {
            if      last.isWhitespace
            {
                string.removeLast()
                continue
            }
            else if last != "]"
            {
                return nil
            }
            else
            {
                break
            }
        }

        let end:String.Index = string.index(before: string.endIndex)
        
        if  let index:String.Index = string[..<end].lastIndex(of: "["),
            let fnv1:UInt32 = .init(string[string.index(after: index) ..< end], radix: 36)
        {
            string = string.prefix(upTo: index)
            self.init(bits: fnv1)
        }
        else
        {
            return nil
        }
    }
}
extension Codelink.Hash:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        .init(self.bits, radix: 36, uppercase: true)
    }
}
