extension IP
{
    @frozen public
    struct Table<Value>
    {
        @usableFromInline internal
        var blocks:[UInt8: [IP.V6: Value]]

        @inlinable public
        init(blocks:[UInt8: [IP.V6: Value]])
        {
            self.blocks = blocks
        }
    }
}
extension IP.Table:Sendable where Value:Sendable
{
}
extension IP.Table:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(UInt8, [IP.V6: Value])...)
    {
        self.init(blocks: .init(uniqueKeysWithValues: elements))
    }
}
extension IP.Table
{
    @inlinable public
    subscript(block:IP.Block<IP.V6>) -> Value?
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
