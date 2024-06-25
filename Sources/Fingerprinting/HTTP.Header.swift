import HTTP

extension HTTP
{
    public
    protocol Header:RawRepresentable<Substring>
    {
        init(rawValue:Substring)
    }
}
extension HTTP.Header
{
    @inlinable public
    init(_ string:String) { self.init(rawValue: string[...]) }
}
extension HTTP.Header where Self:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(rawValue: stringLiteral[...]) }
}
