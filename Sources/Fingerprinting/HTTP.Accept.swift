import HTTP

extension HTTP
{
    @frozen public
    struct Accept:RawRepresentable, Sendable
    {
        public
        var rawValue:String

        @inlinable public
        init(rawValue:String)
        {
            self.rawValue = rawValue
        }
    }
}
extension HTTP.Accept:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(rawValue: stringLiteral) }
}
extension HTTP.Accept:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(parser: .init(string: self.rawValue))
    }
}
