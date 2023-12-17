import JSON
import PackageGraphs
import Symbols

extension SPM.Manifest.Dependency
{
    @frozen public
    struct Filesystem:Equatable, Sendable
    {
        public
        let id:Symbol.Package
        public
        let location:Symbol.FileBase

        @inlinable public
        init(id:Symbol.Package, location:Symbol.FileBase)
        {
            self.id = id
            self.location = location
        }
    }
}
extension SPM.Manifest.Dependency.Filesystem:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "identity"
        case location = "path"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        //  Note: location is not wrapped in a single-element array
        self.init(id: try json[.id].decode(), location: try json[.location].decode())
    }
}
