import Symbols
import Unidoc

extension Compiler
{
    /// A thin wrapper around a dictionary of ``Nomination``s.
    @_eagerMove
    @frozen public
    struct Nominations:Sendable
    {
        @usableFromInline internal
        let nominations:[Symbol.Decl: Nomination]

        init(_ nominations:[Symbol.Decl: Nomination])
        {
            self.nominations = nominations
        }
    }
}
extension Compiler.Nominations
{
    @inlinable public
    subscript(feature scalar:Symbol.Decl) -> (name:String, phylum:Unidoc.Decl)?
    {
        self.nominations[scalar].map { ($0.name, $0.phylum) }
    }
}
