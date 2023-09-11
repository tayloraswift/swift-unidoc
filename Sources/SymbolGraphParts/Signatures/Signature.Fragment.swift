import JSONDecoding
import MarkdownABI
import Signatures
import Symbols

extension Signature<Symbol.Decl>
{
    struct Fragment:Equatable, Hashable, Sendable
    {
        public
        let spelling:String
        public
        let referent:Symbol.Decl?
        public
        let color:Color

        @inlinable public
        init(_ spelling:String, referent:Symbol.Decl? = nil, color:Color)
        {
            self.spelling = spelling
            self.referent = referent
            self.color = color
        }
    }
}
extension Signature.Fragment
{
    func spelled(_ spelling:__owned String) -> Self
    {
        .init(spelling, referent: self.referent, color: self.color)
    }
}
extension Signature.Fragment:JSONObjectDecodable, JSONDecodable
{
    public
    enum CodingKey:String
    {
        case spelling
        case referent = "preciseIdentifier"
        case color = "kind"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(try json[.spelling].decode(),
            referent: try json[.referent]?.decode(),
            color: try json[.color].decode())
    }
}
