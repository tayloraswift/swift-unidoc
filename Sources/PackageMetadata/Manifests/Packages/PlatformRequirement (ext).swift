import JSONDecoding
import ModuleGraphs
import SemanticVersions

extension PlatformRequirement:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "platformName"
        case min = "version"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(id: try json[.id].decode(),
            min: try json[.min].decode(as: JSON.StringRepresentation<NumericVersion>.self,
                with: \.value))
    }
}
