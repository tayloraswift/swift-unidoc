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
        let version:PatchVersion

        public
        init(generator:String, version:PatchVersion)
        {
            self.generator = generator
            self.version = version
        }
    }
}

extension SymbolGraphPart.Metadata:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        case formatVersion
        case generator
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(generator: try json[.generator].decode(),
            version: try json[.formatVersion].decode())
    }
}
