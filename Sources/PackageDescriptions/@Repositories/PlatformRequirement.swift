import JSONDecoding
import SemanticVersions

extension PlatformRequirement:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case id = "platformName"
        case min = "version"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(id: try json[.id].decode(),
            min: try json[.min].decode(as: JSON.StringRepresentation<SemanticVersionMask>.self,
                with: \.value))
    }
}
