import JSONDecoding
import MarkdownABI
import Symbols

struct DeclarationFragment:Equatable, Hashable, Sendable
{
    public
    let spelling:String
    public
    let referent:ScalarSymbol?
    public
    let color:Color

    @inlinable public
    init(_ spelling:String, referent:ScalarSymbol? = nil, color:Color)
    {
        self.spelling = spelling
        self.referent = referent
        self.color = color
    }
}
extension DeclarationFragment
{
    var nominal:Bool
    {
        switch  (self.color, self.spelling)
        {
        case    (.label, _),
                (.identifier, _), 
                (.keyword, "init"),
                (.keyword, "deinit"),
                (.keyword, "subscript"):
            return true
        
        case _:
            return false
        }
    }
}
extension DeclarationFragment
{
    func spelled(_ spelling:__owned String) -> Self
    {
        .init(spelling, referent: self.referent, color: self.color)
    }
}
extension DeclarationFragment:JSONObjectDecodable, JSONDecodable
{
    public
    enum CodingKeys:String
    {
        case spelling
        case referent = "preciseIdentifier"
        case color = "kind"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(try json[.spelling].decode(),
            referent: try json[.referent]?.decode(),
            color: try json[.color].decode())
    }
}
