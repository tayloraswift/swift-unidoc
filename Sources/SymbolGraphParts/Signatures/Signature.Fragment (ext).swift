import JSONDecoding
import MarkdownPluginSwift
import Signatures
import Symbols

extension Signature<Symbol.Decl>.Fragment
{
    func spelled(_ spelling:__owned String) -> Self
    {
        .init(spelling, referent: self.referent)
    }
}
extension Signature<Symbol.Decl>.Fragment:JSONObjectDecodable, JSONDecodable
{
    public
    enum CodingKey:String
    {
        case spelling
        case referent = "preciseIdentifier"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(try json[.spelling].decode(), referent: try json[.referent]?.decode())
    }
}
