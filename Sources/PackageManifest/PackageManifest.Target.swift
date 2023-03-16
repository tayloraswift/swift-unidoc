import JSONDecoding

extension PackageManifest
{
    @frozen public
    struct Target:Identifiable, Equatable, Sendable
    {
        public
        let id:TargetIdentifier
        public
        let dependencies:[TargetDependency]
        /// The path to the target’s source directory, relative to the
        /// package root. If nil, the path is just [`"Sources/\(self.id)"`]().
        public
        let path:String?
        public
        let type:TargetType

        @inlinable public
        init(id:TargetIdentifier,
            dependencies:[TargetDependency] = [],
            path:String? = nil,
            type:TargetType = .library)
        {
            self.id = id
            self.dependencies = dependencies
            self.path = path
            self.type = type
        }
    }
}
extension PackageManifest.Target:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case id = "name"
        case dependencies
        case path
        case type
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(id: try json[.id].decode(),
            dependencies: try json[.dependencies].decode(),
            path: try json[.path]?.decode(),
            type: try json[.type].decode())
    }
}
