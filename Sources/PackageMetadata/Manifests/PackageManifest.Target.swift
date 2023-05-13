import JSONDecoding
import PackageGraphs

extension PackageManifest
{
    @frozen public
    struct Target:Equatable, Sendable
    {
        public
        let name:String
        public
        let type:TargetType
        public
        let dependencies:Dependencies
        /// The path to the target’s source directory, relative to the
        /// package root. If nil, the path is just [`"Sources/\(self.id)"`]().
        public
        let path:String?

        @inlinable public
        init(name:String, type:TargetType = .library,
            dependencies:Dependencies = .init(),
            path:String? = nil)
        {
            self.name = name
            self.type = type
            self.dependencies = dependencies
            self.path = path
        }
    }
}
extension PackageManifest.Target:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case name
        case dependencies
        case path
        case type
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            name: try json[.name].decode(),
            type: try json[.type].decode(as: Keyword.self, with: \.type),
            dependencies: try json[.dependencies].decode(),
            path: try json[.path]?.decode())
    }
}
