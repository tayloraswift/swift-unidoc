import HTTP

extension HTTP
{
    @frozen public
    struct AcceptLanguage:RawRepresentable, Sendable
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
extension HTTP.AcceptLanguage:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(rawValue: stringLiteral) }
}
extension HTTP.AcceptLanguage:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(parser: .init(string: self.rawValue))
    }
}
extension HTTP.AcceptLanguage
{
    /// Returns the locale with the highest quality factor.
    @inlinable public
    var dominant:HTTP.Locale?
    {
        self.max { $0.q < $1.q }?.locale
    }
}
