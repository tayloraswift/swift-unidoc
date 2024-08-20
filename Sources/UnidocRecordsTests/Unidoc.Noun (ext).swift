import FNV1
import Symbols
import Unidoc

extension Unidoc.Noun
{
    static
    func article(_ stem:Unidoc.Stem,
        text:String,
        hash:FNV24? = nil) -> Self
    {
        .init(shoot: .init(stem: stem, hash: hash), type: .text(text))
    }

    static
    func decl(_ stem:Unidoc.Stem,
        language:Phylum.Language = .swift,
        phylum:Phylum.Decl = .struct,
        hash:FNV24? = nil,
        from citizenship:Unidoc.Citizenship = .culture) -> Self
    {
        .init(shoot: .init(
                stem: stem,
                hash: hash),
            type: .stem(citizenship, .init(
                language: language,
                phylum: phylum,
                kinks: [],
                route: .init(underscored: false, hashed: hash != nil))))
    }
}
