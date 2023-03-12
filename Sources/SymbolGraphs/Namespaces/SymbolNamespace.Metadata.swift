import JSONDecoding
import SemanticVersions

extension SymbolNamespace
{
    struct Metadata:Equatable, Sendable
    {
        let generator:String
        let version:SemanticVersion
        init(generator:String, version:SemanticVersion)
        {
            self.generator = generator
            self.version = version
        }
    }
}

extension SymbolNamespace.Metadata:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case formatVersion
        case generator
    }

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(generator: try json[.generator].decode(),
            version: try json[.formatVersion].decode())
    }
}
