import Fragments
import JSONDecoding

extension DeclarationFragment:JSONObjectDecodable, JSONDecodable
    where Symbol:JSONDecodable, Color == DeclarationFragmentClass?
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
            symbol: try json[.symbol]?.decode(),
            color: try json[.color].decode(as: SymbolDescription.FragmentColor.self,
                with: \.classification))
    }
}
