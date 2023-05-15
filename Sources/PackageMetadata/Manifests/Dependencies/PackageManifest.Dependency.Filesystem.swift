import JSONDecoding
import PackageGraphs

extension PackageManifest.Dependency
{
    @frozen public
    struct Filesystem:Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let location:Repository.Root

        @inlinable public
        init(id:PackageIdentifier, location:Repository.Root)
        {
            self.id = id
            self.location = location
        }
    }
}
extension PackageManifest.Dependency.Filesystem:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case id = "identity"
        case location = "path"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        //  Note: location is not wrapped in a single-element array
        self.init(id: try json[.id].decode(), location: try json[.location].decode())
    }
}
