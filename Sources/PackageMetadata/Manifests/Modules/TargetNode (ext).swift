import JSONDecoding
import ModuleGraphs
import PackageGraphs

extension TargetNode:JSONObjectDecodable
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
