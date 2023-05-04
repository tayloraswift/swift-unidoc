import JSONDecoding
import Symbols

extension SymbolRelationship
{
    struct SourceOrigin:Equatable, Hashable, Sendable
    {
        let resolution:ScalarSymbol

        init(_ resolution:ScalarSymbol)
        {
            self.resolution = resolution
        }
    }
}
extension SymbolRelationship.SourceOrigin:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case identifier
    }

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(try json[.identifier].decode())
    }
}
