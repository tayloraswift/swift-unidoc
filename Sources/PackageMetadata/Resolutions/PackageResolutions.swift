import JSONDecoding
import ModuleGraphs

@frozen public
struct PackageResolutions:Equatable, Sendable
{
    public
    let version:FormatVersion
    public
    var pins:[Repository.Pin]

    @inlinable public
    init(version:FormatVersion, pins:[Repository.Pin])
    {
        self.version = version
        self.pins = pins
    }
}
extension PackageResolutions
{
    public
    init(parsing json:String) throws
    {
        try self.init(json: try JSON.Object.init(parsing: json))
    }
}
extension PackageResolutions:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case version

        case object
        enum Object:String, Sendable
        {
            case pins
        }

        case pins
    }
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let version:FormatVersion = try json[.version].decode()
        let pins:[Repository.Pin]
        switch version
        {
        case .v1:
            pins = try json[.object].decode(using: CodingKey.Object.self)
            {
                try $0[.pins].decode
                {
                    try $0.map { try $0.decode(as: Repository.Pin.V1.self, with: \.value) }
                }
            }

        case .v2:
            pins = try json[.pins].decode
            {
                try $0.map { try $0.decode(as: Repository.Pin.V2.self, with: \.value) }
            }
        }
        self.init(version: version, pins: pins)
    }
}
