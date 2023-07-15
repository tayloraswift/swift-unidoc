import JSONDecoding
import Symbols

extension SymbolRelationship
{
    struct SourceOrigin:Equatable, Hashable, Sendable
    {
        let resolution:Symbol.Decl

        init(_ resolution:Symbol.Decl)
        {
            self.resolution = resolution
        }
    }
}
extension SymbolRelationship.SourceOrigin:JSONObjectDecodable
{
    enum CodingKey:String
    {
        case identifier
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(try json[.identifier].decode())
    }
}
