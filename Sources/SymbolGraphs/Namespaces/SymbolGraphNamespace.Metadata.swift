import JSONDecoding

extension SymbolGraphNamespace
{
    struct Metadata:Equatable, Sendable
    {
        let generator:String
        let version:FormatVersion

        init(generator:String, version:FormatVersion)
        {
            self.generator = generator
            self.version = version
        }
    }
}

extension SymbolGraphNamespace.Metadata:JSONObjectDecodable
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
