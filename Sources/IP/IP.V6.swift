extension IP
{
    @frozen public
    struct V6:Equatable, Hashable, Sendable
    {
        public
        var a:UInt16
        public
        var b:UInt16
        public
        var c:UInt16
        public
        var d:UInt16
        public
        var e:UInt16
        public
        var f:UInt16
        public
        var g:UInt16
        public
        var h:UInt16

        @inlinable public
        init(
            _ a:UInt16,
            _ b:UInt16,
            _ c:UInt16,
            _ d:UInt16,
            _ e:UInt16,
            _ f:UInt16,
            _ g:UInt16,
            _ h:UInt16)
        {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            self.f = f
            self.g = g
            self.h = h
        }
    }
}
extension IP.V6:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        withUnsafeBytes(of: self)
        {
            let words:UnsafeBufferPointer<UInt16> = $0.bindMemory(to: UInt16.self)
            return words.lazy.map
            {
                String.init(UInt16.init(bigEndian: $0), radix: 16)
            }.joined(separator: ":")
        }
    }
}
