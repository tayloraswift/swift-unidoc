import JSONDecoding
import Repositories
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
        let reference:Repository.Reference
        if  let version:SemanticVersion = try json[.version]?.decode(
                as: JSON.StringRepresentation<SemanticVersion>.self,
                with: \.value)
        {
            reference = .version(version)
        }
        else
        {
            reference = .branch(try json[.branch].decode())
        }
        self.init(reference: reference, revision: try json[.revision].decode())
    }
}
