import JSON
import SymbolGraphs

extension SPM.Manifest
{
    @frozen public
    struct Product:Equatable, Sendable
    {
        public
        let name:String
        public
        let type:SymbolGraphMetadata.ProductType
        public
        let targets:[String]

        @inlinable public
        init(name:String, type:SymbolGraphMetadata.ProductType, targets:[String])
        {
            self.name = name
            self.type = type
            self.targets = targets
        }
    }
}
extension SPM.Manifest.Product:JSONObjectDecodable
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
