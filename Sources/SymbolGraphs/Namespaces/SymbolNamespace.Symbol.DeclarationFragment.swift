import JSONDecoding

extension SymbolNamespace.Symbol
{
    struct DeclarationFragment:Equatable, Sendable
    {
        let spelling:String
        let symbol:SymbolIdentifier?
        let color:Declaration.FragmentColor

        init(spelling:String,
            symbol:SymbolIdentifier?,
            color:Declaration.FragmentColor)
        {
            self.spelling = spelling
            self.symbol = symbol
            self.color = color
        }
    }
}
extension SymbolNamespace.Symbol.DeclarationFragment:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case spelling
        case symbol = "preciseIdentifier"
        case color = "kind"
    }

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(spelling: try json[.spelling].decode(),
            symbol: try json[.symbol]?.decode(as: SymbolIdentifier.USR.self, with: \.symbol),
            color: try json[.color].decode())
    }
}
