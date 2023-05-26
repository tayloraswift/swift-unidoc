import JSONDecoding
import ModuleGraphs
import PackageGraphs

extension PackageNode.Dependency.Filesystem:JSONObjectDecodable
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
