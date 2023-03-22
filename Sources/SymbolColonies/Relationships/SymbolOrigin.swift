import JSONDecoding

@frozen public
struct SymbolOrigin:Equatable, Hashable, Sendable
{
    public
    let resolution:ScalarSymbolResolution

    @inlinable public
    init(_ resolution:ScalarSymbolResolution)
    {
        self.resolution = resolution
    }
}
extension SymbolOrigin:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case identifier
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(try json[.identifier].decode())
    }
}
