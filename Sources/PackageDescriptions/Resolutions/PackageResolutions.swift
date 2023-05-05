import JSONDecoding

@frozen public
struct PackageResolutions:Equatable, Sendable
{
    public
    var pins:[Repository.Pin]

    @inlinable public
    init(pins:[Repository.Pin])
    {
        self.pins = pins
    }
}
extension PackageResolutions:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Repository.Pin...)
    {
        self.init(pins: arrayLiteral)
    }
}
extension PackageResolutions:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case version
        case pins
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        switch try json[.version].decode(to: UInt.self)
        {
        case 2:
            self.init(pins: try json[.pins].decode())

        case let unsupported:
            throw FormatVersionError.init(unsupported: unsupported)
        }
    }
}
