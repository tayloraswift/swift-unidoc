import JSONDecoding

extension PackageManifest.Dependency
{
    @frozen public
    struct Filesystem:Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let location:PackageRoot

        @inlinable public
        init(id:PackageIdentifier, location:PackageRoot)
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
