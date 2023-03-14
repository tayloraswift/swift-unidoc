import JSONDecoding

@frozen public 
struct PackageResolution:Equatable, Sendable
{
    public
    var pins:[Pin]

    @inlinable public
    init(pins:[Pin])
    {
        self.pins = pins
    }
}
extension PackageResolution:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Pin...)
    {
        self.init(pins: arrayLiteral)
    }
}
extension PackageResolution:JSONObjectDecodable
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
