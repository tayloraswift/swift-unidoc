import JSONDecoding

extension SymbolRelationship
{
    struct SourceOrigin:Equatable, Hashable, Sendable
    {
        let resolution:ScalarSymbolResolution

        init(_ resolution:ScalarSymbolResolution)
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
