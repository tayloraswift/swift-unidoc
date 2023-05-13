import Symbols

extension Compiler
{
    /// A thin wrapper around a dictionary of ``Nomination``s.
    @_eagerMove
    @frozen public
    struct Nominations:Sendable
    {
        @usableFromInline internal
        let nominations:[ScalarSymbol: Nomination]

        init(_ nominations:[ScalarSymbol: Nomination])
        {
            self.nominations = nominations
        }
    }
}
extension Compiler.Nominations
{
    @inlinable public
    subscript(feature scalar:ScalarSymbol) -> (name:String, phylum:ScalarPhylum)?
    {
        self.nominations[scalar].map { ($0.name, $0.phylum) }
    }
}
