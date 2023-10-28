import JSONDecoding
import ModuleGraphs
import SemanticVersions

extension Repository.Pin.State:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case branch
        case revision
        case version
    }
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let version:AnyVersion
        //  `try?` because sometimes we have explicit JSON null
        if  let stable:SemanticVersion = try? json[.version]?.decode(
                as: JSON.StringRepresentation<SemanticVersion>.self,
                with: \.value)
        {
            version = .stable(stable)
        }
        else
        {
            version = try json[.branch].decode(
                as: JSON.StringRepresentation<AnyVersion>.self,
                with: \.value)
        }
        self.init(revision: try json[.revision].decode(), version: version)
    }
}
