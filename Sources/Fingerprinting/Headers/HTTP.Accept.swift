import HTTP

extension HTTP
{
    @frozen public
    struct Accept:Header, Sendable, ExpressibleByStringLiteral
    {
        public
        var rawValue:Substring

        @inlinable public
        init(rawValue:Substring)
        {
            self.rawValue = rawValue
        }
    }
}
extension HTTP.Accept:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(parser: .init(string: self.rawValue))
    }
}
