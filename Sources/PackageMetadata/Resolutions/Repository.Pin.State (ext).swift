import JSONDecoding
import PackageGraphs
import SemanticVersions

extension Repository.Pin.State:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case branch
        case revision
        case version
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        let ref:Repository.Ref
        if  let version:SemanticVersion = try json[.version]?.decode(
                as: JSON.StringRepresentation<SemanticVersion>.self,
                with: \.value)
        {
            ref = .version(version)
        }
        else
        {
            ref = .branch(try json[.branch].decode())
        }
        self.init(revision: try json[.revision].decode(), ref: ref)
    }
}
