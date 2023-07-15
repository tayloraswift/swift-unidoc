import JSONDecoding
import ModuleGraphs
import PackageGraphs

extension PackageNode.Dependency.Filesystem:JSONObjectDecodable
{
    public
    enum CodingKey:String
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
