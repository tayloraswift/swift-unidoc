import JSONDecoding

extension PackageManifest
{
    @frozen public
    struct Product:Identifiable, Equatable, Sendable
    {
        public
        let id:ProductIdentifier
        public
        let targets:[TargetIdentifier]
        public
        let type:ProductType

        @inlinable public
        init(id:ProductIdentifier, targets:[TargetIdentifier], type:ProductType)
        {
            self.id = id
            self.targets = targets
            self.type = type
        }
    }
}
extension PackageManifest.Product:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case id = "name"
        case targets
        case type
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(id: try json[.id].decode(),
            targets: try json[.targets].decode(),
            type: try json[.type].decode())
    }
}
