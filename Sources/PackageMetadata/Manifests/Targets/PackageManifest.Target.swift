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
        /// Paths of excluded files, relative to the target source directory.
        public
        let exclude:[String]
        /// The path to the target’s source directory, relative to the
        /// package root. If nil, the path is just [`"Sources/\(self.id)"`]().
        public
        let path:String?

        @inlinable public
        init(name:String, type:TargetType = .regular,
            dependencies:Dependencies = .init(),
            exclude:[String] = [],
            path:String? = nil)
        {
            self.name = name
            self.type = type
            self.dependencies = dependencies
            self.exclude = exclude
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
        case type
        case dependencies
        case exclude
        case path
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            name: try json[.name].decode(),
            type: try json[.type].decode(),
            dependencies: try json[.dependencies].decode(),
            exclude: try json[.exclude].decode(),
            path: try json[.path]?.decode())
    }
}
