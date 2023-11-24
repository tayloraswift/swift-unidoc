import JSON

extension PackageManifest
{
    @frozen public
    struct DependencyResolutions:Equatable, Sendable
    {
        public
        let format:Format
        public
        var pins:[DependencyPin]

        @inlinable public
        init(format:Format, pins:[DependencyPin])
        {
            self.format = format
            self.pins = pins
        }
    }
}
extension PackageManifest.DependencyResolutions
{
    public
    init(parsing json:String) throws
    {
        try self.init(json: try JSON.Object.init(parsing: json))
    }
}
extension PackageManifest.DependencyResolutions:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case format = "version"

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
        let format:Format = try json[.format].decode()
        let pins:[PackageManifest.DependencyPin]
        switch format
        {
        case .v1:
            pins = try json[.object].decode(using: CodingKey.Object.self)
            {
                try $0[.pins].decode
                {
                    try $0.map
                    {
                        try $0.decode(as: PackageManifest.DependencyPin.V1.self, with: \.value)
                    }
                }
            }

        case .v2:
            pins = try json[.pins].decode
            {
                try $0.map
                {
                    try $0.decode(as: PackageManifest.DependencyPin.V2.self, with: \.value)
                }
            }
        }
        self.init(format: format, pins: pins)
    }
}
