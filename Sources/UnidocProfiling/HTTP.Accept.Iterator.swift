import HTTP

extension HTTP.Accept
{
    @frozen public
    struct Iterator
    {
        @usableFromInline
        var parser:HTTP.AcceptStringIterator

        @inlinable
        init(parser:HTTP.AcceptStringIterator)
        {
            self.parser = parser
        }
    }
}
extension HTTP.Accept.Iterator:IteratorProtocol
{
    @inlinable public mutating
    func next() -> HTTP.Accept.Option?
    {
        while let string:HTTP.AcceptStringParameter = self.parser.next()
        {
            return .init(type: string.key, q: string.q ?? 1.0, v: string.v)
        }

        return nil
    }
}
