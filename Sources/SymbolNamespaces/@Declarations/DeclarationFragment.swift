import JSONDecoding

extension DeclarationFragment<SymbolIdentifier, DeclarationFragmentClass?>:
    JSONObjectDecodable,
    JSONDecodable
{
    public
    enum CodingKeys:String
    {
        case spelling
        case symbol = "preciseIdentifier"
        case color = "kind"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(try json[.spelling].decode(),
            symbol: try json[.symbol]?.decode(as: UnifiedScalarResolution.self,
                with: \.id),
            color: try json[.color].decode(as: SymbolDescription.FragmentColor.self,
                with: \.classification))
    }
}
