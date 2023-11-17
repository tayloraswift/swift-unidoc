extension URI
{
    @frozen public
    struct Fragment:RawRepresentable, Equatable, Hashable, Sendable
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
extension URI.Fragment:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
extension URI.Fragment
{
    @inlinable public
    var encoded:String { EncodingSet.encode(self.rawValue) }
}
extension URI.Fragment:CustomStringConvertible
{
    @inlinable public
    var description:String { "#\(self.encoded)" }
}
