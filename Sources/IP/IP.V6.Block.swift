extension IP.V6
{
    @frozen public
    struct Block:Equatable, Hashable, Sendable
    {
        public
        var base:IP.V6
        public
        var bits:UInt8

        @inlinable public
        init(base:IP.V6, bits:UInt8)
        {
            self.base = base
            self.bits = bits
        }
    }
}
