import JSONDecoding
import ModuleGraphs

extension PackageManifest
{
    @frozen public
    struct Product:Equatable, Sendable
    {
        public
        let name:String
        public
        let type:ProductType
        public
        let targets:[String]

        @inlinable public
        init(name:String, type:ProductType, targets:[String])
        {
            self.name = name
            self.type = type
            self.targets = targets
        }
    }
}
extension PackageManifest.Product:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case name
        case type
        case targets
    }
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(name: try json[.name].decode(), type: try json[.type].decode(),
            targets: try json[.targets].decode())
    }
}
