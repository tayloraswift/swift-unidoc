import JSONDecoding
import Symbols

extension SymbolRelationship
{
    struct SourceOrigin:Equatable, Hashable, Sendable
    {
        let resolution:Symbol.Scalar

        init(_ resolution:Symbol.Scalar)
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
