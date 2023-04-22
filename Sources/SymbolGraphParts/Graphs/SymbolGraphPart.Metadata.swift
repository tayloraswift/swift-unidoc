import JSONDecoding
import SemanticVersions

extension SymbolGraphPart
{
    public
    struct Metadata:Equatable, Sendable
    {
        public
        let generator:String
        public
        let version:SemanticVersion

        public
        init(generator:String, version:SemanticVersion)
        {
            self.generator = generator
            self.version = version
        }
    }
}

extension SymbolGraphPart.Metadata:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case formatVersion
        case generator
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(generator: try json[.generator].decode(),
            version: try json[.formatVersion].decode())
    }
}
