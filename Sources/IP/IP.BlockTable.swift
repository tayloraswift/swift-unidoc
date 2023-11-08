extension IP
{
    @frozen public
    struct BlockTable<Base, Value> where Base:IP.Address
    {
        public
        var blocks:[UInt8: [Base: Value]]

        @inlinable public
        init(blocks:[UInt8: [Base: Value]])
        {
            self.blocks = blocks
        }
    }
}
extension IP.BlockTable:Sendable where Value:Sendable
{
}
extension IP.BlockTable:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(UInt8, [Base: Value])...)
    {
        self.init(blocks: .init(uniqueKeysWithValues: elements))
    }
}
extension IP.BlockTable
{
    @inlinable public mutating
    func update(blocks:some Sequence<IP.Block<Base>>, with value:Value)
    {
        for block:IP.Block<Base> in blocks
        {
            self[block] = value
        }
    }

    @inlinable public
    subscript(block:IP.Block<Base>) -> Value?
    {
        get
        {
            self.blocks[block.bits]?[block.base]
        }
        set(value)
        {
            guard
            let value:Value = value
            else
            {
                return
            }

            self.blocks[block.bits, default: [:]][block.base] = value
        }
    }
}
