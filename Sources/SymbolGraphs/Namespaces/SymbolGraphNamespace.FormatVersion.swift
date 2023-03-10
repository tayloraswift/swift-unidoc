import JSONDecoding
import SemanticVersion

extension SymbolGraphNamespace
{
    struct FormatVersion:Equatable, Sendable
    {
        let semantic:SemanticVersion

        init(_ semantic:SemanticVersion)
        {
            self.semantic = semantic
        }
    }
}
extension SymbolGraphNamespace.FormatVersion:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case major
        case minor
        case patch
    }

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(.init(
            try json[.major].decode(),
            try json[.minor].decode(),
            try json[.patch].decode()))
    }
}
